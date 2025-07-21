//
//  ContactsViewModel.swift
//  NokAI
//
//  Created by Charlotte Lew on 7/10/25.
//

import Foundation
import SwiftUI

class ContactsViewModel: ObservableObject {
    @Published var callHistories: [CallRecord] = []
    @Published var sampleFriends: [FriendDisplay] = []
    @Published var incomingRequests: [LocalFriendRequest] = []
    @Published var outgoingRequests: [LocalFriendRequest] = []

    private var callManager: CallHistoryManager
    private let userDefaults = UserDefaults.standard

    init() {
        let currentUsername = userDefaults.string(forKey: "currentUsername") ?? ""
        self.callManager = CallHistoryManager(currentUsername: currentUsername)
        loadAll()
    }

    func loadAll() {
        loadCallHistories()
        loadRequests()
        loadUser()
    }

    func loadCallHistories() {
        callManager.fetchCallHistory { records in
            DispatchQueue.main.async {
                self.callHistories = records
            }
        }
    }

    func loadRequests() {
        guard let currentUsername = userDefaults.string(forKey: "currentUsername") else { return }

        FriendRequestManager.shared.fetchIncomingRequests(for: currentUsername) { incoming in
            DispatchQueue.main.async {
                self.incomingRequests = incoming.map {
                    LocalFriendRequest(fromUsername: $0["fromUsername"] as? String,
                                       toUsername: $0["toUsername"] as? String,
                                       status: $0["status"] as? String)
                }
            }
        }

        FriendRequestManager.shared.fetchOutgoingRequests(from: currentUsername) { outgoing in
            DispatchQueue.main.async {
                self.outgoingRequests = outgoing.map {
                    LocalFriendRequest(fromUsername: $0["fromUsername"] as? String,
                                       toUsername: $0["toUsername"] as? String,
                                       status: $0["status"] as? String)
                }
            }
        }
    }

    func loadUser() {
        guard let currentUsername = userDefaults.string(forKey: "currentUsername") else { return }

        UserDataManager.shared.listFriends(ofUsername: currentUsername) { friendUsernames in
            var tempFriends: [FriendDisplay] = []
            let group = DispatchGroup()

            for username in friendUsernames {
                group.enter()
                UserDataManager.shared.fetchUser(byUsername: username) { userData in
                    defer { group.leave() }

                    guard let userData = userData else { return }

                    let name = userData["name"] as? String ?? "Unknown"
                    let username = userData["username"] as? String ?? "Unknown"
                    var photo = UIImage(systemName: "person.crop.circle.fill")!

                    if let photoString = userData["profilePhoto"] as? String,
                       let base64 = UserDataManager.shared.extractBase64Data(from: photoString),
                       let imageData = Data(base64Encoded: base64),
                       let image = UIImage(data: imageData) {
                        photo = image
                    }

                    let display = FriendDisplay(name: name, username: "@\(username)", photo: photo)
                    tempFriends.append(display)
                }
            }

            group.notify(queue: .main) {
                self.sampleFriends = tempFriends.sorted { $0.username < $1.username }
            }
        }
    }

    func handleRequest(_ request: LocalFriendRequest, accepted: Bool) {
        guard let from = request.fromUsername, let to = request.toUsername else { return }

        if accepted {
            FriendRequestManager.shared.acceptRequest(from: from, to: to) { success in
                if success {
                    self.loadRequests()
                    self.loadUser()
                }
            }
        } else {
            FriendRequestManager.shared.declineRequest(from: from, to: to) { success in
                if success {
                    self.loadRequests()
                }
            }
        }
    }
}
