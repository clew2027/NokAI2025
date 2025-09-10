# NokAI 🎙️🌍  
**Real-time audio calling app with multilingual live translation**

Built with SwiftUI, Agora, Node.js, WebSockets, Whisper AI, and MongoDB  
Created by [Charlotte Lew](mailto:your.email@example.com)

---

## 🚀 Overview

NokAI is a real-time iOS calling app that breaks language barriers by providing live transcription and translation during phone calls. Inspired by the experience of growing up in a multilingual household, this project aims to empower smoother cross-lingual communication through intuitive design and fast backend processing.

---

## 🧠 Core Features

- **🔊 Live Voice Calling**  
  Built with SwiftUI and Agora SDK for real-time audio streaming between users.

- **✍️ Whisper Transcription**  
  Streams PCM audio over WebSocket to a backend running Whisper AI for speech-to-text.

- **🌐 Real-Time Translation**  
  Transcribed speech is translated using a translation API and displayed on screen.

- **👥 Friend System**  
  Users can send/accept friend requests and view call history. Data is persisted in MongoDB.

- **📱 SwiftUI Interface**  
  Reactive UI built using `@State`, `@Binding`, and `NavigationStack`. UIKit elements are bridged via `UIViewRepresentable`.

---

## 🏗️ App Architecture

### Frontend (iOS – SwiftUI + Agora)
- Manages all call screens and UI logic
- Captures audio via Agora
- Displays real-time transcription and translation

### Backend (Node.js + WebSockets + Whisper)
- Receives and buffers audio from clients
- Transcribes audio via OpenAI Whisper
- Translates transcriptions and sends them back over WebSocket
- Handles user auth, friend requests, and call logs via REST API and MongoDB

---

## 🔁 Interaction Flow

1. User initiates call — Agora establishes real-time audio stream.
2. Audio is streamed via WebSocket to backend.
3. Whisper transcribes and translates speech.
4. Translated messages are sent back to the peer’s device and shown in UI.
5. Call metadata (participants, timestamps, duration) is saved to MongoDB.

---

## 🛠️ Challenges & Fixes

- **WebSocket Latency**  
  *Fix:* Implemented throttling and audio batching to avoid backend overload.

- **Whisper Delay**  
  *Fix:* Reduced chunk sizes and used timestamps to limit reprocessing.

- **SwiftUI–UIKit Compatibility**  
  *Fix:* Wrapped AgoraVideoCanvas using `UIViewRepresentable`.

---

## 🧪 What I Learned

### SwiftUI & iOS Development
- MVVM architecture
- Advanced state management with `@State`, `@Binding`, `@EnvironmentObject`

### Backend Engineering
- Auth, user relationship modeling, and persistence with Express.js + MongoDB

### Real-Time Systems
- Low-latency audio streaming
- Asynchronous handling of WebSocket traffic and translation pipelines

---

## 📦 Tech Stack

- **Frontend:** SwiftUI, Agora SDK  
- **Backend:** Node.js, Express.js, WebSocket  
- **AI:** Whisper AI (speech-to-text), Translation API  
- **Database:** MongoDB  
- **Others:** UIKit, UIViewRepresentable

---

## 🗂️ Project Timeline  
**May 2025 – July 2025**

---
## 📬 Contact

If you have questions, feel free to reach out!  
👩‍💻 Charlotte Lew — clew27@seas.upenn.edu

---

© 2025 Charlotte Lew — Built with love and a passion for meaningful communication ❤️
