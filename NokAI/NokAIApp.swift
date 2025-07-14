//
//  NokAIApp.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/24/25.
//

import SwiftUI

@main
struct NokAIApp: App {
//    let audioSvc       = AVAudioEngineAudioService()
//    let asrSvc         = OpenAIWhisperService(apiKey: …)
//    let translateSvc   = OpenAIChatService(apiKey: …)
//    let ttsSvc         = AVSpeechTTSService()
//    let callVM         = CallViewModel(audioSvc: audioSvc,
//                                       asrSvc: asrSvc,
//                                       translateSvc: translateSvc,
//                                       ttsSvc: ttsSvc)
//    let callView       = CallView(vm: callVM)
    // Inject into SwiftUI App or UINavigationController for UIKit

    //let context = CoreDataManager.shared.context



        var body: some Scene {
            WindowGroup {
                WelcomeView()
            }
        }
}
