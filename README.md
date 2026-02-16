# Dictto

Voice to text, locally — macOS menu bar app for private, offline voice dictation.

## Download

**[Download Dictto-1.0.0.dmg](https://github.com/jhlee111/dictto/releases/latest)**

## Features

### Voice Dictation
- **100% local processing** — All transcription happens on your device. No cloud, complete privacy.
- **Menu bar app** — No dock icon, always accessible from the menu bar
- **Global hotkey** — Press `Shift+Option+D` to start/stop recording
- **Multi-language support** — Korean, English, Japanese, Chinese, and more
- **Direct text insertion** — Pastes transcription into active text field (with Accessibility permission)
- **Clipboard fallback** — Always copies to clipboard
- **Custom dictionaries** — Add specialized vocabulary for better accuracy
- **Sound feedback** — Audio cues for recording start/stop

### Voice Agent Mode
- **Talk to Claude Code** — Press `Shift+Option+S` to speak directly to Claude Code
- **Multi-turn conversations** — Have back-and-forth voice conversations
- **Interactive Q&A** — Claude can ask clarifying questions, you respond by clicking options

### Audio File Transcription
- **Import audio/video files** — Supports m4a, wav, mp3, mp4, mov, and more
- **SRT subtitle export** — Export transcriptions as subtitle files
- **Share Extension** — Share audio from Voice Memos directly to Dictto
- **Progress display** — Real-time progress for longer files

### Claude Code Integration
- **MCP integration** — Connect Claude Code via [dictto-mcp](https://www.npmjs.com/package/dictto-mcp)
- **Custom dictionaries** — Build vocabulary through natural conversation

### General
- **Guided setup** — First-launch walkthrough helps you get started
- **Customizable shortcuts** — Set any key combination for recording
- **Automatic updates** — In-app updates via Sparkle

## Pricing

| | Community (Free) | Personal ($9.99) |
|---|---|---|
| Voice dictation | 1 minute per session | Unlimited |
| File transcription | 3 full-length/month, then 3-min cap | Unlimited |
| Custom dictionaries | 1 dictionary, 5 entries | Multiple, unlimited entries |
| SRT subtitle export | Included | Included |
| MCP integration | — | Included |

One-time purchase. Activate on up to 3 devices.

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon Mac (M1/M2/M3/M4)

## Installation

### Homebrew

```bash
brew tap jhlee111/dictto
brew install --cask dictto
```

### Manual

1. Download `Dictto-1.0.0.dmg` from [Releases](https://github.com/jhlee111/dictto/releases/latest)
2. Open the DMG and drag Dictto to Applications
3. Launch Dictto from Applications
4. Grant Microphone permission when prompted
5. (Optional) Grant Accessibility permission for direct text insertion

## Usage

### Voice Dictation (⇧⌥D)
1. Launch the app (appears in menu bar)
2. Wait for model to load (~30-40 sec for Large v3 Turbo)
3. Press `Shift+Option+D` to start recording
4. Speak
5. Press `Shift+Option+D` again to stop and transcribe
6. Text is automatically pasted (or copied to clipboard)

### Voice Agent Mode (⇧⌥S)
1. Press `Shift+Option+S` to open the Agent overlay
2. Speak your request
3. Press `Shift+Option+S` again to send to Claude Code
4. Wait for Claude's response (streams in real-time)
5. Press `Escape` or click Close to end the session

> **Note**: Requires Claude Code with [dictto-mcp](https://www.npmjs.com/package/dictto-mcp) configured. Personal tier required.

### Audio File Transcription
1. Click menu bar icon → "Import Audio File..."
2. Select an audio or video file
3. Choose transcription language (optional)
4. Click "Transcribe"
5. Copy the result or export as SRT

### Share from Voice Memos
1. Open Voice Memos app
2. Right-click a recording → Share → "Transcribe with Dictto"
3. Dictto opens and starts transcription automatically

## Models

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

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⇧⌥D` | Toggle voice dictation |
| `⇧⌥S` | Toggle voice agent mode |
| `Escape` | Cancel recording / Close agent window |

## Version

v1.0.0
