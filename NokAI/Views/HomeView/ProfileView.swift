//
//  ProfileViewController.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//

import SwiftUI
import SwiftUI

struct ProfileView: View {
    @State private var name: String = "-"
    @State private var username: String = "-"
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 100)

            Text("Name: \(name)")
                .font(.system(size: 20))

            Text("Username: \(username)")
                .font(.system(size: 18))

            Button(action: logOutTapped) {
                Text("Log Out")
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .cornerRadius(8)
            }

            Spacer()
        }
        .onAppear(perform: loadUser)
        .background(Color.white.ignoresSafeArea())
    }

    private func loadUser() {
        guard let currUsername = UserDefaults.standard.string(forKey: "currentUsername"),
              let user = UserDataManager.shared.fetchUser(byUsername: currUsername) else {
            return
        }

        name = user.name ?? "-"
        username = user.username ?? "-"
    }

    private func logOutTapped() {
        UserDefaults.standard.removeObject(forKey: "currentUsername")

        // Switch root view to WelcomeViewController (UIKit) or another SwiftUI view
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = UIHostingController(rootView: WelcomeView())
            window.makeKeyAndVisible()
        }
    }
}
