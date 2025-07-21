//  ViewController.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/26/25.
//

import Foundation
import AgoraRtcKit

class VideoViewModel: NSObject,AgoraRtcEngineDelegate, AgoraAudioFrameDelegate {
    // Agora configuration
    private let appId = "f4d40bc3cf5b4b0f87848d61703297f3"
    private let token = "007eJxTYGB03rYoQNJTLvTWJA2h/7oCj76v3clj5ViSqStpeffD/UUKDGkmKSYGScnGyWmmSSZJBmkW5hYmFilmhuYGxkaW5mnGPzfHZjQEMjKUHZ7LwAiFID4rQ0ZqTk4+AwMA7yAe9Q=="
    private var channelName = "default"

    @Published var isMuted = false
    @Published var isTranslating = false
    @Published var CallHistoryM: CallHistoryManager!
    var agoraKit: AgoraRtcEngineKit!
    
    private(set) var currentUsername: String = ""
    private(set) var peerUsername: String = ""
    private(set) var peerPhoto: UIImage? = nil
    
    var onTranslatedText: ((String) -> Void)?
    let languageCodes = ["en", "es", "fr"]
    @Published var selectedLanguage = 0  // default to English


    func getPeerPhoto() {
        print("loading peer photo")
        UserDataManager.shared.fetchUser(byUsername: peerUsername) { userData in
            guard let userData = userData else { return }
            if let photoString = userData["profilePhoto"] as? String,
               let base64 = UserDataManager.shared.extractBase64Data(from: photoString),
               let data = Data(base64Encoded: base64),
               let image = UIImage(data: data) {
                self.peerPhoto = image
                print("✅ Loaded peer photo")
            }
        }
    }
    func setCallInfo(currentUser: String, peer: String) {
        self.currentUsername = currentUser
        self.peerUsername = peer
        self.CallHistoryM = CallHistoryManager(currentUsername: currentUser)
    }
    
    override init() {
        super.init()
        initializeAgora()
        getPeerPhoto()
    }
    
    public func setChannelName(_ name: String) {
        self.channelName = name
    }
    
    public func getChannelName() -> String {
        return self.channelName
    }

    private func initializeAgora() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: appId, delegate: self)
        agoraKit.enableVideo()
        agoraKit.setAudioFrameDelegate(self)

        agoraKit.setRecordingAudioFrameParametersWithSampleRate(
            16000,
            channel: 1,
            mode: .readOnly,
            samplesPerCall: 1024
        )
    }

    func setupLocalVideo(view: UIView) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.view = view
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        agoraKit.setupLocalVideo(videoCanvas)
        agoraKit.startPreview()
    }
    
    //MARK: join and leave channel

    func joinChannel() {
        let options = AgoraRtcChannelMediaOptions()
        options.channelProfile = .communication
        options.clientRoleType = .broadcaster
        options.publishMicrophoneTrack = true
        options.publishCameraTrack = true
        options.autoSubscribeAudio = true
        options.autoSubscribeVideo = true

        agoraKit.joinChannel(byToken: token, channelId: channelName, uid: 0, mediaOptions: options)
    }

    func leaveChannel(callDuration: TimeInterval) {
        agoraKit.stopPreview()
        agoraKit.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
        CallHistoryM.logCall(to: peerUsername, duration: callDuration)
    }

    //MARK: Toggle functions
    func setMuted(_ muted: Bool) {
        isMuted = muted
        agoraKit.muteLocalAudioStream(muted)
    }

    func setupRemoteVideo(uid: UInt, in view: UIView?) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = view
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
    }
    
    //MARK: RTC engine

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("✅ Joined channel: \(channel) with uid: \(uid)")
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        // You can trigger remote video setup externally from the ViewController
        print("👤 Remote user joined: \(uid)")
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        print("👤 Remote user left: \(uid)")
    }
    
    func onRecordAudioFrame(_ frame: AgoraAudioFrame, channelId: String) -> Bool {
        guard isTranslating else { return true }
        guard let buffer = frame.buffer else {return true}
        print("📥 Captured \(frame.samplesPerSec) samples per sec")
        let length = 1024 * 2
        sendAudioToBackend(buffer: buffer, length: length)
        print("Sending audio")

        return true
        
    }
    
    //MARK: websocket stuff
    
    private var webSocket: URLSessionWebSocketTask?
    
    func connectWebSocket() {
        print("starting websocket connection")
        var targetLanguage = languageCodes[selectedLanguage]

        guard let url = URL(string: "ws://192.168.1.158:8080") else { return }
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
 
        sendConfig()
        receiveWebSocketMessages()
    }
    
    func sendConfig() {
        let config: [String: String] = [
            "type": "config",
            "userId": currentUsername,
            "peerId": peerUsername,
            "target_lang": languageCodes[selectedLanguage],
            "translating": isTranslating.description
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: config),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let message = URLSessionWebSocketTask.Message.string(jsonString)
            webSocket?.send(message) { error in
                if let error = error {
                    print("❌ Failed to send config: \(error)")
                } else {
                    print("✅ Config sent \(jsonString)")
                }
            }
        }
    }
    
    func disconnectWebSocket() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        print("websocket disconnected")
    }
    
    private func sendAudioToBackend(buffer: UnsafeMutableRawPointer, length: Int) {
        let data = Data(bytes: buffer, count: length)
            let message = URLSessionWebSocketTask.Message.data(data)
            
            webSocket?.send(message) { error in
                if let error = error {
                    print("WebSocket send error: \(error)")
                }
            }
    }
    
    private func receiveWebSocketMessages() {
        print("got to recieve web socket in videoVM")
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("🔁 WebSocket received string:", text)
                    if let data = text.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                           json["type"] == "translation",
                           let translated = json["text"] {
                            self?.onTranslatedText?(translated)
                        }
                case .data(let audioData):
                    // self?.playTranslatedAudio(data: audioData)
                    break
                @unknown default:
                    break
                }
            case .failure(let error):
                print("WebSocket receive error: \(error)")
            }

            self?.receiveWebSocketMessages()
        }
    }
    //MARK: toggle translation
    func setTranslationEnabled(_ enabled: Bool) {
        isTranslating = enabled
        if enabled {
            connectWebSocket()
        } else {
            disconnectWebSocket()
        }
    }

}

