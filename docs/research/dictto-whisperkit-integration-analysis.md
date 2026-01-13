# Dictto-WhisperKit Integration Analysis

> Research Date: 2026-01-12
> Purpose: Identify duplications and conflicts between Dictto implementation and WhisperKit internal behavior

## Overview

This document analyzes potential issues where Dictto's implementation may conflict with or duplicate WhisperKit's internal processing.

---

## 1. VAD Chunking - Potential Double Processing

### Current Implementation

```swift
// WhisperKitEngine.swift:274-282
switch vadMode {
case .off:
    chunkingStrategy = .none
case .auto:
    chunkingStrategy = audioDuration > 30.0 ? .vad : .none  // VAD only for >30s
case .always:
    chunkingStrategy = .vad
}
```

### WhisperKit Internal Behavior

```swift
// WhisperKit.swift:903
case (true, .vad):  // audio > 30s + VAD option
    let chunker = VADAudioChunker(vad: vad)
    let audioChunks = try await chunker.chunkAll(...)
```

### Analysis Matrix

| Scenario | Our Setting | WhisperKit Behavior | Result |
|----------|-------------|---------------------|--------|
| ≤30s + VAD off | `.none` | Single pass | ✅ OK |
| ≤30s + VAD always | `.vad` | **VAD analysis runs but no split** | ⚠️ Unnecessary overhead |
| >30s + VAD auto | `.vad` | VAD chunking | ✅ OK |
| >30s + VAD off | `.none` | Fixed 30s windows | ✅ OK (intentional) |

### Issue

When `vadMode: .always` with audio under 30 seconds, VAD analysis still runs but provides no benefit.

### Recommendation

Consider skipping VAD for audio under 30 seconds even when `vadMode: .always`:
```swift
case .always:
    chunkingStrategy = audioDuration > 30.0 ? .vad : .none
```

---

## 2. Streaming Chunking - Internal Re-chunking Risk

### Current Implementation

```swift
// AppState.swift - Fixed 15-second chunking
private let streamingChunkDuration: Double = 15.0

// WhisperKitEngine.swift - No chunkingStrategy for streaming
let options = DecodingOptions(
    task: whisperTask,
    language: language,
    usePrefillPrompt: needsPrefill,
    usePrefillCache: false,
    suppressBlank: false
    // chunkingStrategy NOT passed!
)
```

### WhisperKit Internal Check

```swift
// WhisperKit.swift:902
let isChunkable = audioArray.count > featureExtractor.windowSamples  // ~480,000 samples (30s)
switch (isChunkable, decodeOptions?.chunkingStrategy) {
case (true, .vad):
    // VAD chunking triggered
default:
    // Single pass processing
}
```

### Analysis Matrix

| Our Chunk Size | WhisperKit isChunkable | Result |
|----------------|------------------------|--------|
| 15s (240,000 samples) | false (< 480,000) | ✅ Single pass |
| 25s (400,000 samples) | false (< 480,000) | ✅ Single pass |
| **30s+ (480,000+ samples)** | **true** | ⚠️ **May trigger internal re-chunking** |

### Issue

If our streaming chunks exceed 30 seconds, WhisperKit may re-chunk internally.

### Current Status

**OK** - Current 15-second chunks are well under the 30-second threshold.

### Recommendation

Add safety limit to ensure chunks never exceed 25 seconds:
```swift
private let maxStreamingChunkDuration: Double = 25.0  // Safety margin
```

---

## 3. Progress Calculation Mismatch

### Current Implementation

```swift
// WhisperKitEngine.swift:303
let totalWindows = calculateTotalWindows(audioPath: audioPath)
// → Int(ceil(duration / 30.0))  // Based on fixed 30s windows

// Progress calculation
let progressPercent = Double(windowId + 1) / Double(max(totalWindows, 1))
```

### WhisperKit VAD Behavior

```swift
// When VAD chunking is used, actual chunk count varies
let audioChunks = chunker.chunkAll(...)  // e.g., 5 chunks for 90s audio
// But we expect 3 windows (90s / 30s)
```

### Analysis Matrix

| Audio Length | Expected Windows (30s) | Actual VAD Chunks | Progress Accuracy |
|--------------|------------------------|-------------------|-------------------|
| 60s | 2 | 2-4 (varies) | ❌ Mismatch |
| 90s | 3 | 4-6 (varies) | ❌ Mismatch |
| 120s | 4 | 5-8 (varies) | ❌ Mismatch |

### Issue

Progress percentage may be inaccurate when VAD chunking is active because actual chunk count differs from our 30s-based calculation.

### Recommendation

Option A: Get actual chunk count from WhisperKit callback
```swift
// Use windowId from callback to track actual progress
var maxWindowId = 0
whisperCallback = { progress in
    maxWindowId = max(maxWindowId, progress.windowId)
    // Adjust total estimate dynamically
}
```

Option B: Don't show percentage for VAD mode, show indeterminate progress

---

## 4. Prefill Logic - Potential Conflict

### Current Implementation

```swift
// WhisperKitEngine.swift:258-259
let isShortAudio = audioDuration < 5.0
let needsPrefill = (language != nil) || isShortAudio
```

### WhisperKit Defaults

```swift
// DecodingOptions defaults
usePrefillPrompt: Bool = true   // Default is true
detectLanguage: Bool? = nil     // When nil, follows !usePrefillPrompt
```

### Analysis Matrix

| Scenario | Our Setting | WhisperKit Interpretation | Result |
|----------|-------------|---------------------------|--------|
| Language specified | `usePrefillPrompt: true` | Use prefill | ✅ As intended |
| Auto-detect + long audio | `usePrefillPrompt: false` | No prefill, language detection enabled | ✅ As intended |
| Auto-detect + short audio (<5s) | `usePrefillPrompt: true` | Use prefill | ⚠️ Language detection disabled |

### Issue

For short audio (<5 seconds) with auto-detect language setting, language detection is actually disabled because we enable prefill.

### Reasoning

This is intentional - short audio clips don't have enough context for reliable language detection. Prefill helps ensure the model outputs in a reasonable format.

### Recommendation

Add UI indication when language auto-detect is selected but audio is short:
```
"Note: Language detection works best with recordings over 5 seconds"
```

---

## 5. Streaming Mode - No Context Passing

### Current Implementation

```swift
// AppState.swift - Each chunk processed independently
func transcribeStreamingChunk(_ samples: [Float]) async {
    let result = try await transcriptionService.transcribeChunk(
        audioSamples: samples,
        language: languageCode,
        task: task
        // No promptTokens passed!
    )
    streamingResults.append(result.text)
}
```

### WhisperKit Sequential Mode

```swift
// In sequential mode, WhisperKit passes previous window tokens to next window
// condition_on_previous_text = true (default)
```

### Comparison

| Mode | Context Passing | Expected Quality |
|------|-----------------|------------------|
| File-based (Sequential) | ✅ Yes | High |
| File-based (VAD) | ⚠️ Per-chunk independent | Medium |
| **Streaming (Ours)** | ❌ None | **May be lower** |

### Issue

Streaming chunks have no context from previous chunks, potentially causing:
- Inconsistent capitalization
- Repeated words at boundaries
- Loss of sentence continuity

### Recommendations

**Option A: Pass previous text as context**
```swift
var previousText: String = ""

func transcribeStreamingChunk(_ samples: [Float]) async {
    let result = try await transcriptionService.transcribeChunk(
        audioSamples: samples,
        language: languageCode,
        task: task,
        previousContext: previousText  // Add this
    )
    previousText = result.text
    streamingResults.append(result.text)
}
```

**Option B: Implement VAD-based chunking for streaming**
- Cut at natural speech boundaries
- Reduces need for context passing
- Requires real-time VAD implementation

**Option C: Store and pass token IDs**
```swift
// Requires modifying SpeechResult to include tokens
struct SpeechResult {
    let text: String
    let language: String?
    let tokens: [Int]?  // Add this
}

// Then pass to next chunk
DecodingOptions(
    promptTokens: previousChunkTokens,
    ...
)
```

---

## 6. usePrefillCache: false - Intentional Choice

### Current Implementation

```swift
usePrefillCache: false  // Disable cache to prevent state pollution
```

### Effect

- Fresh prefill cache created for each transcription
- Previous transcription state doesn't affect next one
- Slight performance overhead

### Status

✅ **OK** - This is an intentional choice prioritizing stability over performance.

---

## Summary: Action Items

| Priority | Issue | Impact | Recommended Action |
|----------|-------|--------|-------------------|
| **P1** | Streaming no context passing | Quality degradation | Implement VAD-based chunking OR pass previous context |
| **P2** | Progress calculation mismatch | UX confusion | Recalculate based on actual VAD chunks |
| **P3** | Streaming >30s re-chunking risk | Potential issue | Add 25s max limit (currently OK at 15s) |
| **P4** | Short audio language detection | User confusion | Add UI guidance |
| **P5** | VAD always + short audio | Performance waste | Skip VAD for <30s audio |

---

## Code Locations Reference

| Component | File | Line |
|-----------|------|------|
| VAD mode handling | `WhisperKitEngine.swift` | 274-282 |
| Streaming chunk size | `AppState.swift` | 62 |
| Prefill logic | `WhisperKitEngine.swift` | 258-259 |
| Progress calculation | `WhisperKitEngine.swift` | 303-320 |
| Streaming transcription | `WhisperKitEngine.swift` | 408-453 |
| DecodingOptions (file) | `WhisperKitEngine.swift` | 286-298 |
| DecodingOptions (streaming) | `WhisperKitEngine.swift` | 426-432 |

---

## Related Documents

- [WhisperKit Audio Chunking & VAD Research](./whisperkit-audio-chunking-vad.md)
