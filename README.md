# Dictto

Voice to text, locally - macOS menu bar app for voice dictation using local Whisper model.

## Features

- **Local transcription** - Uses WhisperKit (CoreML) for on-device processing
- **Menu bar app** - No dock icon, always accessible
- **Global hotkey** - Default: `Shift+Option+D` to start/stop recording
- **Multi-language support** - Korean, English, Japanese, Chinese, and more
- **Direct text insertion** - Pastes transcription into active text field (with Accessibility permission)
- **Clipboard fallback** - Always copies to clipboard
- **Sound feedback** - Audio jingles for recording start/stop and transcription complete

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon Mac (M1/M2/M3)

## Model Loading Time

| Model | Size | First Load Time | Note |
|-------|------|-----------------|------|
| Tiny | 74 MB | ~5-10 sec | Fast, less accurate |
| Base | 141 MB | ~10-15 sec | Good balance for English |
| Small | 465 MB | ~20-30 sec | Better accuracy |
| **Large v3 Turbo** | **1.5 GB** | **~30-40 sec** | **Recommended** - Best accuracy |
| Large v3 | 2.9 GB | ~60 sec | Highest accuracy, slower |

> **Note**: First load includes model download from HuggingFace + memory loading. Models are GGML format from [whisper.cpp](https://github.com/ggerganov/whisper.cpp).

## Permissions

| Permission | Required | Purpose |
|------------|----------|---------|
| Microphone | Yes | Record voice |
| Accessibility | Optional | Insert text directly into active field |

## Model Storage

Models are stored in `~/Library/Application Support/Dictto/Models/` (no permission dialogs).

## Build

```bash
# Build release
xcodebuild -scheme Dictto -configuration Release -destination 'platform=macOS' -derivedDataPath ./build build

# Or use the build script
./build-app.sh

# App bundle will be in dist/Dictto.app
```

## Usage

1. Launch the app (appears in menu bar)
2. Wait for model to load (~40 sec for Large v3 Turbo)
3. Press `Shift+Option+D` or click menu bar icon to start recording
4. Speak
5. Press `Shift+Option+D` again to stop and transcribe
6. Text is automatically pasted (or copied to clipboard)

## Tips

- **Short Korean phrases detected as English?** Select "한국어 (Korean)" in Settings → Model → Language instead of "Auto-detect"
- **Faster startup?** Use a smaller model (Tiny or Base) for quicker loading

## Testing

### Unit Tests

```bash
swift test
swift test --filter AppStateTests  # Run specific suite
```

### Integration Tests (TranscriptionService)

Integration tests verify transcription quality using pre-downloaded models and TTS-generated audio fixtures.

**Setup (one-time):**

```bash
# Install huggingface-cli
pip install huggingface_hub

# Download test model (~3GB)
./scripts/download-test-models.sh
```

**Run tests:**

```bash
swift test --filter TranscriptionServiceIntegrationTests
```

**Test audio fixtures** are in `Dictto/Tests/Fixtures/`:
- English: short (~5s), medium (~20s), long (~75s)
- Korean: short (~3s), medium (~20s), long (~65s)

## Version

v0.1.0 - Initial development
