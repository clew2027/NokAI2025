//
//  FriendProfileViewModel.swift
//  NokAI
//
//  Created by Charlotte Lew on 7/11/25.
//

import Foundation
import SwiftUI

class FriendProfileViewModel: ObservableObject {
    @Published var name: String = "-"
    @Published var profileImage: UIImage = UIImage(systemName: "person.crop.circle.fill")!
    @Published var showVideoCall = false
    @Published var currentUsername: String = ""

    func loadFriendProfile(friendUsername: String) {
        currentUsername = UserDefaults.standard.string(forKey: "currentUsername") ?? ""

        UserDataManager.shared.fetchUser(byUsername: friendUsername) { userData in
            guard let userData = userData else { return }

            DispatchQueue.main.async {
                self.name = userData["name"] as? String ?? "-"

                if let photoString = userData["profilePhoto"] as? String,
                   let base64 = UserDataManager.shared.extractBase64Data(from: photoString),
                   let data = Data(base64Encoded: base64),
                   let image = UIImage(data: data) {
                    self.profileImage = image
                }
            }
        }
    }

    func startCall() {
        showVideoCall = true
    }

    func removeContact(friendUsername: String, completion: @escaping (Bool) -> Void) {
        guard let fromUsername = UserDefaults.standard.string(forKey: "currentUsername") else {
            completion(false)
            return
        }

        UserDataManager.shared.removeFriend(userA: fromUsername, userB: friendUsername) { success in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
