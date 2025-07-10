//
//  ViewController.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/26/25.
//

import UIKit
import AgoraRtcKit
import SwiftUI


class ViewController: UIViewController, AgoraAudioFrameDelegate {
    
    let appId = "f4d40bc3cf5b4b0f87848d61703297f3"
    let channelName = "hello"    //replace name
    let token = "007eJxTYGB03rYoQNJTLvTWJA2h/7oCj76v3clj5ViSqStpeffD/UUKDGkmKSYGScnGyWmmSSZJBmkW5hYmFilmhuYGxkaW5mnGPzfHZjQEMjKUHZ7LwAiFID4rQ0ZqTk4+AwMA7yAe9Q=="
    
    // UI view for displaying the local video stream
    var localView: UIView!
    // UI view for displaying the remote video stream
    var remoteView: UIView!
    // Instance of the Agora RTC engine
    var agoraKit: AgoraRtcEngineKit!
    var asrService: ASRService!
    var translationService: TranslationService!
    
    var isMuted = false
    var isCameraOn = true
    // needs testing 
    @objc func didTapMute() {
        isMuted.toggle()
        agoraKit.muteLocalAudioStream(isMuted)
        muteButton.setTitle(isMuted ? "Unmute" : "Mute", for: .normal)
    }

    @objc func didTapCamera() {
        isCameraOn.toggle()

        // Stop sending video to others
        agoraKit.muteLocalVideoStream(!isCameraOn)

        // Stop showing the camera preview to yourself
        if isCameraOn {
            agoraKit.startPreview()
            localView.isHidden = false
        } else {
            agoraKit.stopPreview()
            localView.isHidden = true
        }

        // Update button title
        cameraButton.setTitle(isCameraOn ? "Camera Off" : "Camera On", for: .normal)
    }


    @objc func didTapEndCall() {
        agoraKit.leaveChannel(nil)
        dismiss(animated: true)
        // go to home view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the Agora engine
        initializeAgoraVideoSDK()
        //Set up audio frame
        agoraKit.setAudioFrameDelegate(self)
        // Set up the user interface
        setupUI()
        // Start the local video preview
        setupLocalVideo()
        // Join an Agora channel
        joinChannel()
        
        asrService = ASRService()
        translationService = TranslationService()
    }

    // Clean up resources when the view controller is deallocated
    deinit {
        agoraKit.stopPreview()
        agoraKit.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
    }
    
    // Initializes the Video SDK instance
    func initializeAgoraVideoSDK() {
        // Create an instance of AgoraRtcEngineKit and set the delegate
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: appId, delegate: self)
    }
    
    // Sets up the UI layout for local and remote video views
    func setupUI() {
        // Create the local video view covering the full screen
        localView = UIView(frame: UIScreen.main.bounds)
        
        // Create the remote video view positioned in the top-right corner
        remoteView = UIView(frame: CGRect(x: self.view.bounds.width - 135, y: 50, width: 135, height: 240))
        
        // Add video views to the main view
        self.view.addSubview(localView)
        self.view.addSubview(remoteView)
        muteButton.setTitle("Mute", for: .normal)
        cameraButton.setTitle("Camera Off", for: .normal)
        endCallButton.setTitle("End Call", for: .normal)

        muteButton.addTarget(self, action: #selector(didTapMute), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(didTapCamera), for: .touchUpInside)
        endCallButton.addTarget(self, action: #selector(didTapEndCall), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [muteButton, cameraButton, endCallButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        view.addSubview(stack)

        // Position it
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: 300),
            stack.heightAnchor.constraint(equalToConstant: 50)
        ])

    }
    
    // Configures and starts displaying the local video feed
    func setupLocalVideo() {
        // Enable video functionality (audio is enabled by default)
        agoraKit.enableVideo()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.view = localView
        videoCanvas.uid = 0  // UID 0 is assigned to the local user
        videoCanvas.renderMode = .hidden
        agoraKit.setupLocalVideo(videoCanvas)
        agoraKit.startPreview()
    }

    // Join the channel with specified options
    func joinChannel() {
        let options = AgoraRtcChannelMediaOptions()
        // In video calling, set the channel use-case to communication
        options.channelProfile = .communication
        // Set the user role as broadcaster (default is audience)
        options.clientRoleType = .broadcaster
        // Publish audio captured by microphone
        options.publishMicrophoneTrack = true
        // Publish video captured by camera
        options.publishCameraTrack = true
        // Auto subscribe to all audio streams
        options.autoSubscribeAudio = true
        // Auto subscribe to all video streams
        options.autoSubscribeVideo = true
        // If you set uid=0, the engine generates a uid internally; on success, it triggers didJoinChannel callback
        // Join the channel with a temporary token
        agoraKit.joinChannel(
            byToken: token,
            channelId: channelName,
            uid: 0,
            mediaOptions: options
        )
    }
    
    func setupRemoteVideo(uid: UInt, view: UIView?) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = view // Assign view for joining, set to nil for leaving
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
    }
}

// Extension for handling Agora SDK callbacks
extension ViewController: AgoraRtcEngineDelegate {
    
    // Triggered when the local user successfully joins a channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("Successfully joined channel: \(channel) with UID: \(uid)")
    }
    
    // Triggered when a remote user joins the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        setupRemoteVideo(uid: uid, view: remoteView)
    }

    // Triggered when a remote user leaves the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        setupRemoteVideo(uid: uid, view: nil)
    }
}

//extension ViewController: AgoraAudioFrameDelegate {
//    func onRecord(_ frame: AgoraAudioFrame) -> Bool {
//        let byteCount = Int(frame.samplesPerChannel * frame.channels * 2)
//        let audioData = Data(bytes: frame.buffer, count: byteCount)
//
//        // Send to ASR
//        asrService.transcribeLiveAudio(data: audioData) { [weak self] transcript in
//            DispatchQueue.main.async {
//                self?.transcriptLabel.text = "Transcript: \(transcript)"
//            }
//            self?.translationService.translate(text: transcript) { translation in
//                DispatchQueue.main.async {
//                    self?.translationLabel.text = "Translation: \(translation)"
//                }
//            }
//        }
//        return true
//    }

let muteButton = UIButton(type: .system)
let cameraButton = UIButton(type: .system)
let endCallButton = UIButton(type: .system)


