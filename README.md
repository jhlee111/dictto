# Dictto

**Real-time voice-to-text that runs entirely on your Mac.**

[![Dictto Demo Video](https://img.youtube.com/vi/QOF2-9m8YNU/maxresdefault.jpg)](https://youtu.be/QOF2-9m8YNU)

<p align="center">
  <a href="https://github.com/jhlee111/dictto/releases/latest">
    <img src="https://img.shields.io/badge/Download-Dictto%20for%20Mac-blue?style=for-the-badge&logo=apple" alt="Download Dictto">
  </a>
</p>

Most dictation apps make you choose: **fast** or **private**. Cloud-based transcription streams text as you speak, but your voice leaves your device. Local processing keeps everything private, but you wait until recording ends.

**Dictto does both.** Text appears while you speak, and nothing ever leaves your Mac.

## Why Dictto?

### For Developers & AI Users

If you're working with Claude Code, Cursor, or any LLM — speaking your prompts is faster than typing. But waiting for transcription breaks your flow.

With Dictto, your words become text instantly. Send prompts while still talking. Your instructions don't need perfect grammar — LLMs understand context. What matters is **speed**, **accuracy**, and **privacy**.

### Real-time Streaming + Local = No Compromise

- **See words as you speak** — Not after you stop
- **100% on-device** — Voice never touches the cloud
- **Powered by Whisper** — OpenAI's speech recognition, running locally via WhisperKit
- **Works offline** — No internet required after initial model download

## Features

- **Global Hotkey** — Press ⇧⌥D from any app to start/stop
- **Auto-Paste** — Text goes directly where your cursor is
- **Multilingual** — English, Korean, Japanese, Chinese, and 90+ languages
- **Menu Bar App** — Stays out of your way until you need it
- **Apple Silicon Optimized** — Runs efficiently on M1/M2/M3/M4

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
2. Press **⇧⌥D** (or click Record)
3. Speak — watch text appear in real-time
4. Press **⇧⌥D** again to stop
5. Text is copied and pasted automatically

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
- Audio is deleted immediately after transcription

## Documentation

See the [User Guide](docs/USER_GUIDE.md) for detailed documentation.

## Support

If you encounter any issues:

1. Check the [User Guide](docs/USER_GUIDE.md) for troubleshooting
2. Open an [Issue](https://github.com/jhlee111/dictto/issues) with your system info

## License

Proprietary software. All rights reserved.

---

Made with ❤️ for macOS
