# Dictto

Voice to text, locally - macOS menu bar app for private, offline voice dictation.

## Download

**[Download Dictto-0.15.0.dmg](https://github.com/jhlee111/dictto/releases/latest)**

## Features

- **Local transcription** - All processing happens on your device, no cloud required
- **Menu bar app** - No dock icon, always accessible
- **Global hotkey** - Default: `Shift+Option+D` to start/stop recording
- **Multi-language support** - Korean, English, Japanese, Chinese, and more
- **Direct text insertion** - Pastes transcription into active text field (with Accessibility permission)
- **Clipboard fallback** - Always copies to clipboard
- **Sound feedback** - Audio jingles for recording start/stop
- **Audio file import** - Import from Voice Memos or other audio files (m4a, wav, mp3, mp4)
- **Speaker diarization** - Identify and label different speakers in audio files
- **Speaker identification** - Assign names to speakers during transcription review
- **Share Extension** - Share audio from Voice Memos directly to Dictto
- **Guided setup** - First-launch walkthrough helps you get started quickly
- **Instant feedback** - "Copied!" confirmation so you always know your transcription is ready
- **Customizable shortcuts** - Set any key combination for recording, including Escape
- **Automatic updates** - Get notified of new versions with in-app updates
- **Long file support** - Progress display for files over 30 seconds
- **Claude Code integration** - Connect Claude Code via MCP for AI-assisted speaker review ([dictto-mcp](https://www.npmjs.com/package/dictto-mcp))

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon Mac (M1/M2/M3/M4)

## Installation

1. Download `Dictto-0.15.0.dmg` from [Releases](https://github.com/jhlee111/dictto/releases/latest)
2. Open the DMG and drag Dictto to Applications
3. Launch Dictto from Applications
4. Grant Microphone permission when prompted
5. (Optional) Grant Accessibility permission for direct text insertion

## Usage

### Voice Recording
1. Launch the app (appears in menu bar)
2. Wait for model to load (~30-40 sec for Large v3 Turbo)
3. Press `Shift+Option+D` or click menu bar icon to start recording
4. Speak
5. Press `Shift+Option+D` again to stop and transcribe
6. Text is automatically pasted (or copied to clipboard)

### Audio File Import
1. Click menu bar icon → "Import Audio File..."
2. Select an audio file (m4a, wav, mp3, mp4)
3. Choose transcription language (optional)
4. Enable "Speaker Diarization" to identify different speakers (optional)
5. Click "Transcribe"
6. For long files (>30s), progress and partial results are shown in real-time
7. Copy the result or let it auto-copy to clipboard

### Share from Voice Memos
1. Open Voice Memos app
2. Right-click a recording → Share → "Transcribe with Dictto"
3. Dictto opens and starts transcription automatically

## Model

| Model | Size | Load Time | Note |
|-------|------|-----------|------|
| Tiny | 74 MB | ~5-10 sec | Fast, less accurate |
| Base | 141 MB | ~10-15 sec | Good for English |
| Small | 465 MB | ~20-30 sec | Better accuracy |
| **Large v3 Turbo** | **1.5 GB** | **~30-40 sec** | **Recommended** |
| Large v3 | 2.9 GB | ~60 sec | Highest accuracy |

> Models are downloaded automatically on first use.

## Permissions

| Permission | Required | Purpose |
|------------|----------|---------|
| Microphone | Yes | Record voice |
| Accessibility | Optional | Insert text directly into active field |

## Tips

- **Short Korean phrases detected as English?** Select "한국어 (Korean)" in Settings → Language instead of "Auto-detect"
- **Faster startup?** Use a smaller model (Tiny or Base) for quicker loading
- **Long recordings?** Use "Import Audio..." for pre-recorded files with progress tracking

## License

MIT License

## Version

v0.15.0
