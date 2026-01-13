# WhisperKit Audio Chunking & VAD Research

> Research Date: 2026-01-12
> Related to: Streaming transcription implementation

## Overview

This document covers how WhisperKit and Whisper handle audio chunking, VAD (Voice Activity Detection), and context passing between segments.

---

## 1. Whisper Model's 30-Second Limitation

### Core Architecture

- Whisper processes audio in **maximum 30-second windows** (480,000 samples @ 16kHz)
- This is a fundamental model architecture limitation
- Audio shorter than 30 seconds is processed in a single pass

### Audio Length vs Quality

| Audio Length | Processing | Quality Impact |
|-------------|-----------|----------------|
| < 30s | Single pass | **Optimal** - full context maintained |
| = 30s | Single pass | Optimal |
| > 30s | Multiple windows | Potential quality loss at boundaries |

**Key insight: Shorter audio is NOT disadvantageous. Under 30 seconds is actually optimal.**

---

## 2. Long-Form Transcription Strategies

### Strategy 1: Sequential (Default)

```
[Window 1: 0-30s] → decode → tokens
        ↓ (pass previous tokens as prompt)
[Window 2: 30-60s] → decode → tokens
        ↓
[Window 3: 60-90s] → ...
```

**Characteristics:**
- `condition_on_previous_text=True` (default)
- Previous window's output tokens passed as **prompt** to next window
- Maintains contextual continuity
- Slower (sequential processing)

### Strategy 2: Chunked (Parallel)

```
[Chunk 1: 0-30s]   → decode ─┐
[Chunk 2: 28-58s]  → decode ─┼→ merge at overlap
[Chunk 3: 56-86s]  → decode ─┘
```

**Characteristics:**
- **2-3 second overlap** between chunks
- Find **Longest Common Sequence (LCS)** in overlap for merging
- No context passing between chunks
- Faster (parallel processing)

---

## 3. Boundary Handling

### Whisper's Smart Boundary Detection

When a sentence doesn't end at the 30-second boundary:

```
Window end with incomplete segment?
    ↓
Analyze timestamp tokens
    ↓
"Rewind" to last completed segment
    ↓
Next window starts from that point
```

**Example:**
```
Audio: "The weather is really nice today. Tomorrow..."
        |-------- 30s boundary --------|

Before: "The weather is really nice today. Tomor" | "row..."  ❌ word split
After:  "The weather is really nice today."      | "Tomorrow..." ✅ rewind
```

---

## 4. WhisperKit VAD Implementation

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        WhisperKit                                │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────────┐  │
│  │  EnergyVAD   │ →  │ VADAudioChunker│ →  │  Whisper Model   │  │
│  │ (energy-based)│    │ (chunk split)  │    │ (transcription)  │  │
│  └──────────────┘    └──────────────┘    └──────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Key Point: VAD is handled by WhisperKit, NOT by Whisper model itself.**

### EnergyVAD Class

Location: `/Sources/WhisperKit/Core/Audio/EnergyVAD.swift`

```swift
public final class EnergyVAD: VoiceActivityDetector {
    public let energyThreshold: Float  // default: 0.02

    // Parameters
    // - sampleRate: 16000 (default)
    // - frameLength: 0.1s (100ms frames)
    // - frameOverlap: 0.0s
    // - energyThreshold: 0.02

    // Logic:
    // - Calculate energy per 100ms frame
    // - energy > threshold → speech
    // - energy < threshold → silence
}
```

### VADAudioChunker Class

Location: `/Sources/WhisperKit/Core/Audio/AudioChunker.swift`

```swift
open class VADAudioChunker: AudioChunking {
    private let windowPadding: Int  // 16000 samples (1 second)
    private let vad: VoiceActivityDetector

    func chunkAll(audioArray: [Float], maxChunkLength: Int, ...) {
        // 1. If audio <= maxChunkLength (30s), return as-is
        // 2. If audio > 30s:
        //    - Find longest silence in second half
        //    - Split at middle of silence
        //    - Repeat
    }
}
```

### Split Logic Detail

```swift
func splitOnMiddleOfLongestSilence(audioArray, startIndex, endIndex) {
    // 1. Analyze VAD on second half (50%~100%) of chunk
    let audioMidIndex = startIndex + (endIndex - startIndex) / 2
    let vadAudioSlice = Array(audioArray[audioMidIndex..<endIndex])

    // 2. Find longest silence
    let voiceActivity = vad.voiceActivity(in: vadAudioSlice)
    if let silence = vad.findLongestSilence(in: voiceActivity) {
        // 3. Split at middle of silence
        let silenceMidIndex = silence.startIndex + (silence.endIndex - silence.startIndex) / 2
        return audioMidIndex + vad.voiceActivityIndexToAudioSampleIndex(silenceMidIndex)
    }
    return endIndex  // No silence found, use full chunk
}
```

### Usage Flow (WhisperKit.swift:903)

```swift
switch (isChunkable, decodeOptions?.chunkingStrategy) {
case (true, .vad):
    // Audio > 30s + VAD option → use VADAudioChunker
    let vad = voiceActivityDetector ?? EnergyVAD()
    let chunker = VADAudioChunker(vad: vad)
    let audioChunks = try await chunker.chunkAll(audioArray: audioArray, ...)

    // Transcribe each chunk separately
    let results = await transcribeWithOptions(audioChunks.map { $0.audioSamples }, ...)

default:
    // Audio <= 30s or no VAD → single transcription
    transcribeResults = try await runTranscribeTask(audioArray: audioArray, ...)
}
```

---

## 5. DecodingOptions Reference

### All Available Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| task | DecodingTask | .transcribe | .transcribe or .translate |
| language | String? | nil | Language code (nil = auto-detect) |
| temperature | Float | 0.0 | Sampling temperature |
| temperatureIncrementOnFallback | Float | 0.2 | Temperature increase on fallback |
| temperatureFallbackCount | Int | 5 | Max fallback attempts |
| topK | Int | 5 | Top-K sampling |
| usePrefillPrompt | Bool | true | Use prompt prefill |
| usePrefillCache | Bool | true | Use prefill cache |
| detectLanguage | Bool? | nil | Language detection (nil = !usePrefillPrompt) |
| skipSpecialTokens | Bool | false | Skip special tokens |
| withoutTimestamps | Bool | false | Disable timestamps |
| wordTimestamps | Bool | false | Word-level timestamps |
| suppressBlank | Bool | false | Suppress blank outputs |
| supressTokens | [Int] | [] | Token IDs to suppress |
| compressionRatioThreshold | Float? | 2.4 | Repetition detection |
| logProbThreshold | Float? | -1.0 | Low-confidence filter |
| firstTokenLogProbThreshold | Float? | -1.5 | First token filter |
| noSpeechThreshold | Float? | 0.6 | Silence detection |
| chunkingStrategy | ChunkingStrategy? | nil | .none or .vad |
| promptTokens | [Int]? | nil | Previous context tokens |
| prefixTokens | [Int]? | nil | Force output prefix |
| concurrentWorkerCount | Int | 16 (macOS) | Parallel workers |

### Currently Used in Dictto

**File-based transcription:**
```swift
DecodingOptions(
    task: whisperTask,
    language: language,
    usePrefillPrompt: needsPrefill,  // true if language specified or short audio
    usePrefillCache: false,          // prevent state pollution
    suppressBlank: false,
    compressionRatioThreshold: 2.4,
    logProbThreshold: -1.0,
    firstTokenLogProbThreshold: -1.5,
    noSpeechThreshold: 0.6,
    chunkingStrategy: chunkingStrategy  // based on VAD mode setting
)
```

**Streaming chunk transcription:**
```swift
DecodingOptions(
    task: whisperTask,
    language: language,
    usePrefillPrompt: needsPrefill,
    usePrefillCache: false,
    suppressBlank: false
)
```

---

## 6. Implications for Streaming Implementation

### Current Limitation

WhisperKit's VAD analyzes **complete audio files** after recording ends.
For streaming, we need **real-time VAD** during recording.

### Comparison

| Aspect | WhisperKit VAD | Our Streaming Need |
|--------|---------------|-------------------|
| Timing | Post-recording analysis | Real-time analysis |
| Method | Energy-based (simple) | Same approach works |
| Split point | Middle of longest silence | End of silence |

### Recommended Real-time VAD Implementation

```swift
// Real-time VAD for streaming (same energy-based approach)
class RealtimeVAD {
    let energyThreshold: Float = 0.02
    var silenceDuration: Double = 0

    func processAudioSamples(_ samples: [Float], sampleRate: Double) -> Bool {
        let energy = calculateRMS(samples)

        if energy < energyThreshold {
            // Silence detected
            silenceDuration += Double(samples.count) / sampleRate
            return silenceDuration > 0.5  // 0.5s silence = end of speech
        } else {
            silenceDuration = 0
            return false
        }
    }

    private func calculateRMS(_ samples: [Float]) -> Float {
        let sumOfSquares = samples.reduce(0) { $0 + $1 * $1 }
        return sqrt(sumOfSquares / Float(samples.count))
    }
}

// Usage in streaming
func handleAudioSamples(_ samples: [Float]) {
    buffer.append(samples)

    if vad.processAudioSamples(samples) && buffer.duration > 3.0 {
        // Silence detected + min 3s buffer → send chunk
        processChunk(buffer)
        buffer.clear()
    }

    // Safety: force send at 25s (stay under 30s limit)
    if buffer.duration > 25.0 {
        processChunk(buffer)
        buffer.clear()
    }
}
```

---

## 7. Quality Improvement Options

### Priority 1: promptTokens (Context Passing)

Pass previous chunk's tokens to maintain context:
```swift
// Requires storing token IDs from WhisperKit response
var previousChunkTokens: [Int] = []

DecodingOptions(
    promptTokens: previousChunkTokens,  // context from previous chunk
    ...
)
```

**Note:** Currently `SpeechResult` only returns text, not token IDs. Would need to modify to access tokens.

### Priority 2: Temperature Fallback

Enable automatic retry with higher temperature on failure:
```swift
DecodingOptions(
    temperature: 0.0,
    temperatureIncrementOnFallback: 0.2,
    temperatureFallbackCount: 3,  // retry up to 3 times
    ...
)
```

### Priority 3: Threshold Tuning

Adjust thresholds based on use case:
```swift
DecodingOptions(
    compressionRatioThreshold: 2.0,  // lower = more sensitive to repetition
    noSpeechThreshold: 0.7,          // higher = more tolerant of silence
    ...
)
```

---

## 8. External VAD Libraries (Alternative)

If more sophisticated VAD is needed:

| Library | Model | Size | Speed | Accuracy |
|---------|-------|------|-------|----------|
| [ios-vad](https://github.com/baochuquan/ios-vad) - WebRTC | GMM | 158KB | Fastest | Lower |
| [ios-vad](https://github.com/baochuquan/ios-vad) - Silero | DNN/ONNX | ~2MB | Fast | High |
| [RealTimeCutVADLibrary](https://github.com/helloooideeeeea/RealTimeCutVADLibrary) | Silero | ~2MB | Fast | High |
| WhisperKit EnergyVAD | Energy | 0 | Fastest | Medium |

---

## References

- [Whisper Long-Form Transcription (Medium)](https://medium.com/@yoad/whisper-long-form-transcription-1924c94a9b86)
- [Whisper Chunking Discussion #1977](https://github.com/openai/whisper/discussions/1977)
- [Whisper Hallucination Discussion #679](https://github.com/openai/whisper/discussions/679)
- [WhisperKit Source Code](https://github.com/argmaxinc/WhisperKit)
- [Speeding up Whisper (Batched)](https://mobiusml.github.io/batched_whisper_blog/)
