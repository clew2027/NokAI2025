//
//  FriendProfileViewController.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//
import SwiftUI
import UIKit

struct FriendProfileView: View {
    let friendUsername: String
    @Binding var showProfileView: Bool
    @Binding var selectedUsername: String?

    @State private var name: String = ""
    @State private var profileImage: UIImage = UIImage(systemName: "person.crop.circle.fill")!
    @State private var showVideoCall = false
    @State private var currentUsername: String = ""

    var body: some View {
        ZStack {
            Color("LightGreen").ignoresSafeArea()

            VStack(spacing: 24) {
                // ✅ Custom Back Button
                HStack {
                    Button(action: {
                        showProfileView = false
                        selectedUsername = nil
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.custom("VT323-Regular", size: 20))
                        .foregroundColor(Color("AccentGreen"))
                        .padding()
                    }
                    Spacer()
                }

                Spacer().frame(height: 20)

                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color("AccentGreen"), lineWidth: 3))

                Text(name)
                    .font(.custom("VT323-Regular", size: 32))
                    .foregroundColor(Color("AccentGreen"))

                Text("@\(friendUsername)")
                    .font(.custom("VT323-Regular", size: 20))
                    .foregroundColor(Color("AccentGreen"))

                Button(action: {
                    startCall()
                }) {
                    Text("Start Call")
                        .font(.custom("VT323-Regular", size: 20))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 10)
                        .background(Color("AccentPurple"))
                        .cornerRadius(8)
                }

                Button(action: {
                    removeContact()
                }) {
                    Text("Remove Contact")
                        .font(.custom("VT323-Regular", size: 18))
                        .foregroundColor(Color.red)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red, lineWidth: 1)
                        )
                }

                Spacer()
            }
            .padding()
        }
        .onAppear {
            loadFriendProfile()
        }
        .fullScreenCover(isPresented: $showVideoCall) {
            VideoViewWrapper(
                currentUsername: currentUsername,
                peerUsername: friendUsername
            )
        }
    }

    private func loadFriendProfile() {
        guard let user = UserDataManager.shared.fetchUser(byUsername: friendUsername) else { return }
        name = user.name ?? "-"
        currentUsername = UserDefaults.standard.string(forKey: "currentUsername") ?? ""

        if let data = user.profileImage, let img = UIImage(data: data) {
            profileImage = img
        }
    }

    private func startCall() {
        showVideoCall = true
    }

    private func removeContact() {
        guard let fromUsername = UserDefaults.standard.string(forKey: "currentUsername") else { return }
        UserDataManager.shared.removeFriend(fromUsername: fromUsername, friendUsername: friendUsername)
    }
}


struct VideoViewWrapper: UIViewControllerRepresentable {
    let currentUsername: String
    let peerUsername: String

    func makeUIViewController(context: Context) -> VideoViewController {
        let vc = VideoViewController()
        let channel = [currentUsername, peerUsername].sorted().joined(separator: "_")
        vc.channelName = channel
        vc.currentUsername = currentUsername
        vc.peerUsername = peerUsername
        return vc
    }

    func updateUIViewController(_ uiViewController: VideoViewController, context: Context) {}
}


