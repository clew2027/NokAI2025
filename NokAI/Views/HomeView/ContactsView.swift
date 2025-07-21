//
//  ContactsView.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//

import SwiftUI
import CoreData

struct LocalFriendRequest: Identifiable {
    var id: String { "\(fromUsername ?? "from")-\(toUsername ?? "to")" }
    let fromUsername: String?
    let toUsername: String?
    let status: String?
}

struct FriendDisplay: Identifiable {
    var id: String { username }
    let name: String
    let username: String
    let photo: UIImage
}

struct ContactsView: View {
    @StateObject private var viewModel = ContactsViewModel()
    @State private var showSearchView = false
    @State private var showProfileView = false
    @State private var selectedUsername: String?

    var body: some View {
        Group {
            if showSearchView {
                SearchView(showSearchView: $showSearchView)
            } else if showProfileView, let username = selectedUsername {
                FriendProfileView(
                    friendUsername: username,
                    showProfileView: $showProfileView,
                    selectedUsername: $selectedUsername
                )
            } else {
                contactsMainView
            }
        }
    }

    var contactsMainView: some View {
        ZStack(alignment: .top) {
            Color("LightGreen").ignoresSafeArea()
            Image("background")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                HStack {
                    Text("Contacts")
                        .font(.custom("VT323-Regular", size: 32))
                        .foregroundColor(.white)
                        .padding(.leading, 24)
                    Spacer()
                    Button(action: {
                        showSearchView = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color("AccentPurple"))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 24)
                }
                .padding(.top, 50)
                .onAppear {
                    viewModel.loadAll()
                }
                .frame(height: 100)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(viewModel.sampleFriends) { friend in
                            Button(action: {
                                selectedUsername = friend.username.replacingOccurrences(of: "@", with: "")
                                showProfileView = true
                            }) {
                                VStack(spacing: 4) {
                                    Image(uiImage: friend.photo)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 72, height: 72)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color("LightGreen"), lineWidth: 7)
                                        )
                                    Text(friend.name)
                                        .font(.custom("VT323-Regular", size: 14))
                                        .foregroundColor(.black)
                                    Text(friend.username)
                                        .font(.custom("VT323-Regular", size: 14))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color("AccentPurple"))
                                        .foregroundColor(Color("AccentGreen"))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 15)
                    .padding(.bottom, 36)
                }

                if !viewModel.incomingRequests.isEmpty || !viewModel.outgoingRequests.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Friend Requests")
                            .font(.custom("VT323-Regular", size: 24))
                            .foregroundColor(.black)
                            .padding(.leading, 24)

                        ForEach(viewModel.incomingRequests, id: \.id) { request in
                            HStack {
                                Text("@\(request.fromUsername ?? "")")
                                    .font(.custom("VT323-Regular", size: 16))
                                    .foregroundColor(.black)
                                Spacer()
                                Button("Accept") {
                                    viewModel.handleRequest(request, accepted: true)
                                }
                                .font(.custom("VT323-Regular", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .cornerRadius(4)

                                Button("Decline") {
                                    viewModel.handleRequest(request, accepted: false)
                                }
                                .font(.custom("VT323-Regular", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(4)
                            }
                            .padding(.horizontal, 32)
                        }

                        ForEach(viewModel.outgoingRequests, id: \.id) { request in
                            HStack {
                                Text("To @\(request.toUsername ?? "")")
                                    .font(.custom("VT323-Regular", size: 16))
                                Spacer()
                                Text("Pending")
                                    .font(.custom("VT323-Regular", size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Call History")
                        .font(.custom("VT323-Regular", size: 24))
                        .foregroundColor(.black)
                        .padding(.leading, 24)

                    ScrollView {
                        ForEach(viewModel.callHistories) { call in
                            CallHistoryCard(entry: call)
                        }
                    }
                    .frame(height: 400)
                    .padding(.horizontal, 16)
                }

                Spacer()
            }
        }
    }
}
