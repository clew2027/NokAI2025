//
//  Search.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
import SwiftUI

struct UserSearchResult: Identifiable, Decodable {
    var id: String { username }
    let username: String
    let name: String?
    let profilePhoto: String?
}

struct SearchView: View {
    @Binding var showSearchView: Bool

    @State private var searchText = ""
    @State private var searchResults: [UserSearchResult]?
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            Color("LightGreen").ignoresSafeArea()

            VStack {
                // Custom green back button
                HStack {
                    Button(action: {
                        showSearchView = false
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.custom("VT323-Regular", size: 24))
                        .foregroundColor(Color("AccentGreen"))
                        .padding()
                    }
                    Spacer()
                }

                TextField("Search usernames...", text: $searchText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                List(searchResults ?? [], id: \.username) { user in
                    Button {
                        handleSelection(user: user)
                    } label: {
                        Text(user.username ?? "")
                            .font(.custom("VT323-Regular", size: 18))
                    }
                }
                .listStyle(.plain)
            }
            .padding(.top)
        }
        .onChange(of: searchText) { newValue in
            performSearch(query: newValue)
        }
        .alert("Oops", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = nil
            return
        }

        UserDataManager.shared.performSearch(query: query) { results in
                self.searchResults = results
            }
    }

    private func handleSelection(user: UserSearchResult) {
        let toUsername = user.id
        guard let fromUsername = UserDefaults.standard.string(forKey: "currentUsername") else {
            return
        }

        // 1. Fetch current user's friends from the backend
        UserDataManager.shared.listFriends(ofUsername: fromUsername) { friends in
            if friends.contains(toUsername) {
                alertMessage = "You are already friends with \(toUsername)"
                showAlert = true
                return
            }

            // 2. Check if a friend request has already been sent
            FriendRequestManager.shared.fetchOutgoingRequests(from: fromUsername) { requests in
                if requests.contains(where: {
                    ($0["toUsername"] as? String) == toUsername &&
                    ($0["status"] as? String) == "pending"
                }) {
                    alertMessage = "Friend request already sent to \(toUsername)"
                    showAlert = true
                    return
                }

                // 3. Send the request
                FriendRequestManager.shared.sendRequest(from: fromUsername, to: toUsername) { success in
                    alertMessage = success
                        ? "Friend request sent to \(toUsername)."
                        : "Failed to send friend request."
                    showAlert = true
                }
            }
        }
    }

}
