# Dictto

**Voice to text transcription for macOS. 100% local, powered by Whisper.**

[![Dictto Demo Video](https://img.youtube.com/vi/QOF2-9m8YNU/maxresdefault.jpg)](https://youtu.be/QOF2-9m8YNU)

Dictto is a macOS menu bar application that transcribes your voice to text using OpenAI's Whisper models. Everything runs locally on your Mac — no internet required, no data sent to the cloud.

## Features

- **100% Local Processing** — Your voice never leaves your Mac
- **Works Offline** — No internet required after model download
- **Global Keyboard Shortcut** — Record from any app with ⇧⌥D
- **Auto-Paste** — Transcribed text goes directly into your active text field
- **Multiple Languages** — English, Korean, Japanese, Chinese, and more
- **Real-time Streaming** — See transcription as you speak

## Screenshots

<p align="center">
  <img src="docs/images/menu-idle.png" alt="Menu Bar" width="240">
  <img src="docs/images/menu-recording.png" alt="Recording" width="240">
</p>

<p align="center">
  <img src="docs/images/settings-general.png" alt="Settings - General" width="380">
  <img src="docs/images/settings-model.png" alt="Settings - Model" width="380">
</p>

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon Mac (M1, M2, M3, M4)
- ~1GB storage for AI models

## Installation

1. Download the latest release from [Releases](https://github.com/jhlee111/dictto/releases)
2. Open the DMG and drag Dictto to Applications
3. Launch Dictto — it will appear in your menu bar
4. Grant Microphone permission when prompted
5. (Optional) Grant Accessibility permission for auto-paste

## Quick Start

1. Click the Dictto icon in your menu bar
2. Click **Record** (or press **⇧⌥D**)
3. Speak into your microphone
4. Click **Stop** (or press **⇧⌥D** again)
5. Your text is copied to clipboard!

## Documentation

See the [User Guide](docs/help.html) for detailed documentation.

## Model Selection

| Model | Size | Speed | Accuracy |
|-------|------|-------|----------|
| Tiny | ~75 MB | Fastest | Basic |
| Base | ~150 MB | Fast | Good |
| Small | ~500 MB | Medium | Better |
| **Turbo** | ~954 MB | Fast | Excellent |
| Large v3 | ~950 MB | Slower | Best |

**Recommendation:** Use **Turbo** (default) for the best balance of speed and accuracy.

## Privacy

- All processing happens locally on your Mac
- No data is sent to any server
- No analytics or tracking
- Audio recordings are deleted after transcription

## Support

If you encounter any issues:

1. Check the [User Guide](docs/help.html) for troubleshooting
2. Open an [Issue](https://github.com/jhlee111/dictto/issues) with your system info

## License

Proprietary software. All rights reserved.

---

Made with ❤️ for macOS
