# TwinMind

An iOS app for real-time audio recording and 30-second transcription using AVAudioEngine, SwiftUI, and SwiftData.

## Features
- 🎙 Background-safe audio recording
- 🧠 30-second audio segmentation with Whisper or fallback transcription
- 💾 SwiftData storage for sessions and transcripts
- 📱 SwiftUI interface with real-time updates
- 🔁 Retry + offline queuing for failed transcriptions

## Tech Stack
- SwiftUI, AVFoundation, SwiftData
- Whisper (OpenAI) or iOS speech recognition fallback
- Secure API calls with retry logic
- Background Mode support (Audio)
