//
//  SearchViewController.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
import SwiftUI
import CoreData

struct SearchView: View {
    @Binding var showSearchView: Bool

    @State private var searchText = ""
    @State private var searchResults: [User] = []
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

                List(searchResults, id: \.objectID) { user in
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
            searchResults = []
            return
        }

        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username CONTAINS[cd] %@", query)

        do {
            let users = try context.fetch(request)
            if let currentUsername = UserDefaults.standard.string(forKey: "currentUsername") {
                searchResults = users.filter { $0.username != currentUsername }
            } else {
                searchResults = users
            }
        } catch {
            print("Search failed: \(error)")
            searchResults = []
        }
    }

    private func handleSelection(user: User) {
        guard let toUsername = user.username,
              let fromUsername = UserDefaults.standard.string(forKey: "currentUsername"),
              let currentUser = UserDataManager.shared.fetchUser(byUsername: fromUsername) else {
            return
        }

        if alreadyFriends(with: toUsername, currentUser: currentUser) {
            alertMessage = "You are already friends with \(toUsername)"
            showAlert = true
            return
        }

        let outgoing = FriendRequestManager.shared.fetchOutgoingRequests(from: fromUsername)
        if outgoing.contains(where: { $0.toUsername == toUsername && $0.status == "pending" }) {
            alertMessage = "Friend request already sent to \(toUsername)"
            showAlert = true
            return
        }

        FriendRequestManager.shared.sendRequest(from: fromUsername, to: toUsername)
        alertMessage = "Friend request sent to \(toUsername)."
        showAlert = true
    }

    private func alreadyFriends(with targetUsername: String, currentUser: User) -> Bool {
        guard let friends = currentUser.friends as? Set<Friend> else { return false }
        return friends.contains { $0.friendUsername == targetUsername }
    }
}
