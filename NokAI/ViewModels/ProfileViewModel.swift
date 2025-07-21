//
//  ProfileViewModel.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//

import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var name: String = "-"
    @Published var username: String = "-"
    @Published var profileImage: UIImage = UIImage(systemName: "person.circle")!

    func loadUser() {
        guard let currUsername = UserDefaults.standard.string(forKey: "currentUsername") else { return }

        UserDataManager.shared.fetchUser(byUsername: currUsername) { userData in
            guard let user = userData else { return }

            DispatchQueue.main.async {
                self.name = user["name"] as? String ?? "-"
                self.username = user["username"] as? String ?? "-"

                if let photoString = user["profilePhoto"] as? String,
                   let base64 = UserDataManager.shared.extractBase64Data(from: photoString),
                   let data = Data(base64Encoded: base64),
                   let image = UIImage(data: data) {
                    self.profileImage = image
                }
            }
        }
    }

    func logOut() {
        UserDefaults.standard.removeObject(forKey: "currentUsername")

        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                window.rootViewController = UIHostingController(rootView: WelcomeView())
                window.makeKeyAndVisible()
            }
        }
    }
}
