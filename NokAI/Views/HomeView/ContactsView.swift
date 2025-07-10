//
//  ContactsViewController.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.

import SwiftUI
import SwiftUI

struct ContactsView: View {
    @State private var friends: [Friend] = []
    @State private var friendRequests: [FriendRequest] = []
    @State private var outgoingRequests: [FriendRequest] = []
    @State private var navigateToSearch = false
    @State private var selectedFriendUsername: String?

    var body: some View {
        NavigationView {
            List {
                if !friendRequests.isEmpty {
                    Section(header: Text("Friend Requests")) {
                        ForEach(friendRequests, id: \.objectID) { request in
                            HStack {
                                Text(request.fromUsername ?? "-")
                                Spacer()
                                Button("Accept") {
                                    FriendRequestManager.shared.acceptRequest(request)
                                    loadFriends()
                                }
                                Button("Decline") {
                                    FriendRequestManager.shared.declineRequest(request)
                                    loadFriends()
                                }
                            }
                        }
                    }
                }

                if !outgoingRequests.isEmpty {
                    Section(header: Text("Pending Sent")) {
                        ForEach(outgoingRequests, id: \.objectID) { request in
                            Text("Pending: \(request.toUsername ?? "-")")
                                .foregroundColor(.gray)
                        }
                    }
                }

                Section(header: Text("Friends")) {
                    ForEach(friends, id: \.objectID) { friend in
                        NavigationLink(destination: FriendProfileView(friendUsername: friend.friendUsername ?? "")) {
                            Text(friend.friendUsername ?? "")
                        }
                    }
                }
            }
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        navigateToSearch = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                loadFriends()
                NotificationCenter.default.addObserver(forName: .friendListShouldReload, object: nil, queue: .main) { _ in
                    loadFriends()
                }
            }
            .background(
                NavigationLink(destination: SearchView(), isActive: $navigateToSearch) {
                    EmptyView()
                }
            )
        }
    }

    func loadFriends() {
        guard let currUsername = UserDefaults.standard.string(forKey: "currentUsername"),
              let user = UserDataManager.shared.fetchUser(byUsername: currUsername),
              let friendSet = user.friends as? Set<Friend> else {
            self.friends = []
            self.friendRequests = []
            self.outgoingRequests = []
            return
        }

        self.friends = Array(friendSet).sorted { ($0.friendUsername ?? "") < ($1.friendUsername ?? "") }
        self.friendRequests = FriendRequestManager.shared.fetchIncomingRequests(for: currUsername)
        self.outgoingRequests = FriendRequestManager.shared.fetchOutgoingRequests(from: currUsername)
    }
}
