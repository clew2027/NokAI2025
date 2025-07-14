import SwiftUI

struct VideoCallView: View {
    @ObservedObject var viewModel: VideoViewModelWrapper
    @Environment(\.dismiss) var dismiss
    @State private var callDuration: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Color("AccentBlack")
                .ignoresSafeArea()

            VStack {
                // TOP: Peer info + Timer
                VStack(spacing: 8) {
                    // Placeholder for peer profile image
                    if let uiImage = viewModel.viewModel.peerPhoto {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color("LightGreen"), lineWidth: 4))
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color("LightGreen"), lineWidth: 4))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Text(viewModel.viewModel.peerUsername)
                        .font(.custom("VT323-Regular", size: 24))
                        .foregroundColor(Color("AccentGreen"))

                    Text(timerFormatted(callDuration))
                        .font(.custom("VT323-Regular", size: 18))
                        .foregroundColor(Color("AccentGreen"))
                }
                .padding(.top, 40)

                Spacer()

                // TRANSLATION TOGGLE + PANEL
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Translation:")
                            .font(.custom("VT323-Regular", size: 18))
                            .foregroundColor(Color("AccentGreen"))

                        Toggle(isOn: $viewModel.translationEnabled) {
                            EmptyView()
                        }
                        .onChange(of: viewModel.translationEnabled) { enabled in
                            viewModel.viewModel.isTranslating = enabled
                            if enabled {
                                viewModel.viewModel.connectWebSocket()
                            } else {
                                viewModel.viewModel.disconnectWebSocket()
                            }
                        }
                        .onChange(of: viewModel.viewModel.selectedLanguage) { _ in
                            if viewModel.translationEnabled {
                                viewModel.viewModel.sendConfig()
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color("AccentGreen")))
                    }

                    Picker("Language", selection: $viewModel.viewModel.selectedLanguage) {
                        Text("EN").tag(0)
                        Text("ES").tag(1)
                        Text("FR").tag(2)
                    }
                    .pickerStyle(.segmented)

                    TextEditor(text: $viewModel.translatedText)
                        .font(.custom("VT323-Regular", size: 24))
                        .foregroundColor(Color("AccentGreen"))
                        .frame(height: 160)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("AccentGreen"), lineWidth: 1))
                }
                .padding()
                .background(Color("AccentPurple"))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal)
                .padding(.bottom)

                // CONTROL BUTTONS
                HStack(spacing: 30) {
                    Button(viewModel.viewModel.isMuted ? "Unmute" : "Mute") {
                        viewModel.toggleAudioMute()
                    }
                    .buttonStyle(ControlButtonStyle())

                    Button("End Call") {
                        viewModel.leaveChannel(CallDuration: callDuration)
                        dismiss()
                    }
                    .buttonStyle(ControlButtonStyle())
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            viewModel.viewModel.joinChannel()
            viewModel.viewModel.connectWebSocket()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    func timerFormatted(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            callDuration += 1
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
