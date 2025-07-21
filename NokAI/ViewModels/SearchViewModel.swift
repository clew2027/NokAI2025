//
//  SearchViewModel.swift
//  NokAI
//
//  Created by Charlotte Lew on 7/11/25.
//

import Foundation
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [UserSearchResult]? = nil
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = nil
            return
        }

        UserDataManager.shared.performSearch(query: searchText) { results in
            DispatchQueue.main.async {
                self.searchResults = results
            }
        }
    }

    func handleSelection(user: UserSearchResult) {
        let toUsername = user.username
        guard let fromUsername = UserDefaults.standard.string(forKey: "currentUsername") else {
            return
        }

        UserDataManager.shared.listFriends(ofUsername: fromUsername) { friends in
            if friends.contains(toUsername) {
                DispatchQueue.main.async {
                    self.alertTitle = "Already Friends"
                    self.alertMessage = "You are already friends with \(toUsername)"
                    self.showAlert = true
                }
                return
            }

            FriendRequestManager.shared.fetchOutgoingRequests(from: fromUsername) { requests in
                if requests.contains(where: {
                    ($0["toUsername"] as? String) == toUsername &&
                    ($0["status"] as? String) == "pending"
                }) {
                    DispatchQueue.main.async {
                        self.alertTitle = "Request Sent"
                        self.alertMessage = "Friend request already sent to \(toUsername)"
                        self.showAlert = true
                    }
                    return
                }

                FriendRequestManager.shared.sendRequest(from: fromUsername, to: toUsername) { success in
                    DispatchQueue.main.async {
                        self.alertTitle = "Friend Request"
                        self.alertMessage = success
                            ? "Friend request sent to \(toUsername)."
                            : "Failed to send friend request."
                        self.showAlert = true
                    }
                }
            }
        }
    }
}
