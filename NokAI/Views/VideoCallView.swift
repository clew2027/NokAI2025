//
//  VideoView.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//

import SwiftUI

struct VideoCallView: View {
    @ObservedObject var viewModel: VideoViewModelWrapper
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            AgoraVideoView { view in
                viewModel.viewModel.setupLocalVideo(view: view)
            }
            .ignoresSafeArea()

            VStack {
                // TOP BAR
                HStack {
                    Spacer()
                    Text("Calling: \(viewModel.viewModel.peerUsername)")
                        .font(.custom("VT323-Regular", size: 24))
                        .foregroundColor(Color("AccentGreen"))
                    Spacer()
                }
                .padding()
                .background(Color("AccentPurple"))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Spacer()

                // TRANSLATION TOGGLE + PANEL
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Translation:")
                            .font(.custom("VT323-Regular", size: 18))
                            .foregroundColor(Color("AccentGreen"))

                        Toggle(isOn: $viewModel.translationEnabled) {
                            EmptyView()
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color("AccentGreen")))
                    }

                    Picker("Language", selection: $viewModel.selectedLanguage) {
                        Text("EN").tag(0)
                        Text("ES").tag(1)
                        Text("FR").tag(2)
                    }
                    .pickerStyle(.segmented)

                    TextEditor(text: $viewModel.translatedText)
                        .font(.custom("VT323-Regular", size: 16))
                        .foregroundColor(Color("AccentGreen"))
                        .background(Color.clear)
                        .frame(height: 100)
                }
                .padding()
                .background(Color("AccentPurple"))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal)

                // BUTTONS
                HStack {
                    Button(viewModel.viewModel.isMuted ? "Unmute" : "Mute") {
                        viewModel.viewModel.toggleAudioMute()
                    }
                    .buttonStyle(ControlButtonStyle())

                    Button(viewModel.viewModel.isCameraOn ? "Camera Off" : "Camera On") {
                        viewModel.viewModel.toggleCamera(on: viewModel.localView)
                    }
                    .buttonStyle(ControlButtonStyle())

                    Button("End Call") {
                        viewModel.viewModel.leaveChannel()
                        dismiss()
                    }
                    .buttonStyle(ControlButtonStyle())
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            viewModel.viewModel.joinChannel()
        }
    }
}

struct ControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("VT323-Regular", size: 18))
            .foregroundColor(Color("AccentGreen"))
            .padding(.horizontal)
    }
}
