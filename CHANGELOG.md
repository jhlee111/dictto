# Changelog

## v1.0.0

First production release.

### Voice Dictation
- Real-time local transcription powered by Whisper (whisper.cpp on Apple Silicon)
- Global hotkey (⇧⌥D) — start/stop from anywhere
- Direct text insertion via Accessibility or clipboard fallback
- Multi-language support (100+ languages)
- Custom dictionaries for specialized vocabulary
- Audio feedback for recording start/stop

### Voice Agent Mode
- Talk to Claude Code with ⇧⌥S
- Multi-turn voice conversations with session persistence
- Interactive Q&A — Claude asks questions, you click to respond

### File Transcription
- Import audio and video files (m4a, wav, mp3, mp4, mov, etc.)
- SRT subtitle export with timestamps
- Share Extension — share from Voice Memos directly to Dictto
- Real-time progress display for longer files

### Claude Code Integration (MCP)
- [dictto-mcp](https://www.npmjs.com/package/dictto-mcp) — 4 tools for Claude Code
- Transcribe files, manage dictionaries, check status from terminal

### Licensing
- Community (Free) — 1-min dictation, 3-min file transcription, 1 dictionary
- Personal ($9.99 one-time) — unlimited everything, MCP, SRT export, 3 devices
- Powered by Lemon Squeezy

### General
- macOS 14.0+ (Sonoma), Apple Silicon required
- Guided first-launch setup
- Customizable keyboard shortcuts
- Automatic updates via Sparkle
- Homebrew: `brew tap jhlee111/dictto && brew install --cask dictto`
