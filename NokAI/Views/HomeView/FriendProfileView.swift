//
//  FriendProfileView.swift
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

    @StateObject private var viewModel = FriendProfileViewModel()

    var body: some View {
        ZStack {
            Color("LightGreen").ignoresSafeArea()

            VStack(spacing: 24) {
                // Back Button
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

                Image(uiImage: viewModel.profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color("AccentGreen"), lineWidth: 3))

                Text(viewModel.name)
                    .font(.custom("VT323-Regular", size: 32))
                    .foregroundColor(Color("AccentGreen"))

                Text("@\(friendUsername)")
                    .font(.custom("VT323-Regular", size: 20))
                    .foregroundColor(Color("AccentGreen"))

                Button(action: {
                    viewModel.startCall()
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
                    viewModel.removeContact(friendUsername: friendUsername) { success in
                        if success {
                            showProfileView = false
                            selectedUsername = nil
                        } else {
                            print("❌ Failed to remove friend.")
                        }
                    }
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
            viewModel.loadFriendProfile(friendUsername: friendUsername)
        }
        .fullScreenCover(isPresented: $viewModel.showVideoCall) {
            VideoCallView(
                viewModel: VideoViewModelWrapper(
                    currentUsername: viewModel.currentUsername,
                    peerUsername: friendUsername,
                    channelName: "call-\(viewModel.currentUsername)-\(friendUsername)"
                )
            )
        }
    }
}
