//
//  VideoViewModelWrapper.swift
//  NokAI
//
//  Created by Charlotte Lew on 7/7/25.
//

import Combine
import UIKit

class VideoViewModelWrapper: ObservableObject {
    var viewModel = VideoViewModel()

    @Published var translationEnabled: Bool = false {
        didSet {
            viewModel.setTranslationEnabled(translationEnabled)
        }
    }
    
    @Published var translatedText: String = ""
    @Published var isMuted: Bool = false
    @Published var isCameraOn: Bool = true

    var localView = UIView()

    init(currentUsername: String, peerUsername: String, channelName: String) {
        viewModel.setCallInfo(currentUser: currentUsername, peer: peerUsername)
        viewModel.setChannelName(channelName)

        viewModel.onTranslatedText = { [weak self] text in
            DispatchQueue.main.async {
                self?.translatedText = text
                print("translated text: \(text)")
            }
        }
        viewModel.getPeerPhoto()
    }
    
    func toggleAudioMute() {
        isMuted.toggle()
        viewModel.setMuted(isMuted)
    }
    func leaveChannel(CallDuration: TimeInterval) {
        viewModel.leaveChannel(callDuration: CallDuration)
    }
}
