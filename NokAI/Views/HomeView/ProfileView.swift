//
//  ProfileView.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
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

                    Image(uiImage: viewModel.profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("LightGreen"), lineWidth: 4))
                        .offset(y: 60)
                }
                .frame(height: 180)
                .padding(.top, -40)
                .padding(.bottom, 200)

                Text(viewModel.name)
                    .font(.custom("VT323-Regular", size: 24))
                    .foregroundColor(.black)

                Text("@\(viewModel.username)")
                    .font(.custom("VT323-Regular", size: 18))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color("AccentPurple"))
                    .foregroundColor(Color("AccentGreen"))
                    .cornerRadius(6)

                Button(action: viewModel.logOut) {
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
        .onAppear {
            viewModel.loadUser()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
