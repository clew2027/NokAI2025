//
//  ProfileView.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var name: String = "-"
    @State private var username: String = "-"
    @State private var profileImage: UIImage = UIImage(systemName: "person.circle")!
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Color("LightGreen").ignoresSafeArea()

            VStack(spacing: 24) {
                // Top Elliptical Background with profile image
                ZStack(alignment: .bottom) {
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 500)
                        .clipShape(Ellipse())
                        .overlay(Ellipse().stroke(Color.clear))
                        .padding(.top, -150)
                    
                    
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 160)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color("LightGreen"), lineWidth: 4))
                            .offset(y: 60)
                }
                .frame(height: 180)
                .padding(.top, -40)
                .padding(.bottom, 200) // pulls other content up

                // Name
                Text(name)
                    .font(.custom("VT323-Regular", size: 24))
                    .foregroundColor(.black)

                // Username badge
                Text("@\(username)")
                    .font(.custom("VT323-Regular", size: 18))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color("AccentPurple"))
                    .foregroundColor(Color("AccentGreen"))
                    .cornerRadius(6)

                // Log Out Button
                Button(action: logOutTapped) {
                    Text("Log Out")
                        .font(.custom("VT323-Regular", size: 20))
                        .foregroundColor(Color("AccentPurple"))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color("AccentGreen"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color("AccentPurple"), lineWidth: 1)
                        )
                        .cornerRadius(6)
                }

                Spacer()
            }
        }
        .onAppear(perform: loadUser)
        .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }

    private func loadUser() {
        guard let currUsername = UserDefaults.standard.string(forKey: "currentUsername") else { return }
        UserDataManager.shared.fetchUser(byUsername: currUsername) { userData in
            guard let user = userData else { return }

            name = user["name"] as? String ?? "-"
            username = user["username"] as? String ?? "-"

            if let photoString = user["profilePhoto"] as? String,
               let base64 = UserDataManager.shared.extractBase64Data(from: photoString),
               let data = Data(base64Encoded: base64),
               let image = UIImage(data: data) {
                profileImage = image
            }
        }
    }

    private func logOutTapped() {
        UserDefaults.standard.removeObject(forKey: "currentUsername")

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = UIHostingController(rootView: WelcomeView())
            window.makeKeyAndVisible()
        }
    }
}
