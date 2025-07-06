# TwinMind – iOS Audio Recording & Transcription App

TwinMind is an iOS SwiftUI application that enables real-time audio recording in 30-second segments, performs automatic transcription using OpenAI Whisper (with Apple STT fallback), stores sessions locally with encryption, and allows users to chat with the transcript.

## ✅ Features Implemented

### 1. Audio Recording
- Records audio using `AVAudioEngine`.
- Automatically splits into 30-second chunks.
- Displays real-time mic level meter.

### 2. Transcription
- Transcribes chunks using OpenAI Whisper API.
- Fallback to Apple Speech Recognition API after 5 consecutive failures.
- Retry logic with exponential backoff for resilience.

### 3. Offline Support
- Records and queues chunks locally when offline.
- Automatically transcribes them when the internet returns.

### 4. User Interface & UX
- **Tabbed interface**: `Transcript`, `Notes`, and `Questions`.
- **Transcript Tab**: Displays live transcript updates every 30s.
- **Notes Tab**: Auto-generated title and summary after session ends.
- **Questions Tab**: Displays previously asked Q&A per session.
- **Real-time UI elements**:
  - Elapsed timer with red indicator.
  - Audio level meter bar.
- **Transcript Chat Panel**:
  - Ask free-form or suggested questions.
  - Toggle web search option.
  - Results stored per session in local DB.
- **Question Detail View**:
  - Modal to view previous Q&A (with follow-up CTA placeholder).

### 5. Data Security
- Audio chunks are **encrypted at rest** using AES-GCM via CryptoKit.
- Symmetric key securely stored in **Keychain**.
- Decryption performed before uploading to OpenAI or Apple STT.

### 6. Persistence
- Uses **SwiftData** to store:
  - `RecordingSession`
  - `TranscriptChunk`
  - `QAItem`
- UI updates reactively via `@Query` and `@Model`.

---

## 🛠 Tech Stack

- **SwiftUI**
- **SwiftData**
- **AVFoundation**
- **OpenAI Whisper API**
- **Apple Speech API**
- **CryptoKit + Keychain**
- **Modular Architecture** (`Services`, `ViewModels`, `Models`, `Components`)

## 🔐 Permissions Used

This app requests the following iOS permissions:

- **Microphone Access**  
  For real-time audio capture via `AVAudioEngine`.

- **Speech Recognition Access**  
  Required for Apple Speech-to-Text fallback using `SFSpeechRecognizer`.

- **Local Storage Access**  
  Managed via SwiftData for storing session metadata, transcripts, and Q&A.

- **Keychain Access**  
  To securely store the AES encryption key for audio chunk encryption.

> 📌 All permissions are requested only when needed and handled gracefully with fallbacks.

---

## 🚀 How to Run the App

Follow these steps to clone, configure, and run the TwinMind app locally:

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/twinmind-ios.git
cd twinmind-ios
```

### 2. Open in Xcode

- Open the `.xcodeproj` or `.xcworkspace` in **Xcode 15+**
- Ensure the selected target is `TwinMind` and a real device or simulator

### 3. Configure the OpenAI API Key

To use the Whisper API for transcription, add your key to `Info.plist`:

```xml
<key>OPENAI_API_KEY</key>
<string>sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxx</string>
```

You can obtain a key at: [https://platform.openai.com/account/api-keys](https://platform.openai.com/account/api-keys)

### 4. Run the App

- Press **Cmd+R** or click the ▶️ Run button in Xcode.
- Grant microphone and speech permissions when prompted.
- Click "Record" to begin a new session.
