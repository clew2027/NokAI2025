//
//  WelcomeView.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//

import SwiftUI

struct WelcomeView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false
    @State private var showSignup = false
    
    var body: some View {
        Group {
            if showSignup {
                SignupView(isPresented: $showSignup)
            } else if isLoggedIn {
                HomeView()
            } else {
                ZStack {
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Spacer().frame(height: 100)
                        
                        Text("Welcome to")
                            .font(.custom("VT323", size: 48))
                            .foregroundColor(Color("AccentGreen"))
                        
                        Text("NokAI")
                            .font(.custom("VT323", size: 96))
                            .foregroundColor(Color("AccentGreen"))
                        
                        Spacer().frame(height: 60)
                        
                        Group {
                            CustomTextField(text: $username, placeholder: "Username")
                            CustomSecureField(text: $password, placeholder:"Password")
                        }
                        
                        Button(action: {
                            if username.isEmpty || password.isEmpty {
                                alertMessage = "Please enter a username and password"
                                showAlert = true
                            } else {
                                UserDataManager.shared.validateLogin(username: username, password: password) { success in
                                    if success {
                                        UserDefaults.standard.set(username, forKey: "currentUsername")
                                        isLoggedIn = true
                                    } else {
                                        alertMessage = "Invalid username or password"
                                        showAlert = true
                                    }
                                }
                            }
                            
                        }) {
                            Text("Log In")
                                .font(.custom("VT323", size: 22))
                                .foregroundColor(Color("AccentGreen"))
                                .frame(width: 120, height: 36)
                                .background(Color("AccentPurple").opacity(0.9))
                                .cornerRadius(4)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color("AccentGreen"), lineWidth: 1))
                        }
                        
                        Button(action: {
                            showSignup = true
                        }) {
                            HStack(spacing: 0) {
                                Text("New here? ")
                                    .font(.custom("VT323", size: 18))
                                    .foregroundColor(Color("AccentBlack"))
                                Text("Sign Up")
                                    .font(.custom("VT323", size: 18))
                                    .foregroundColor(Color("AccentGreen"))
                                    .underline()
                            }
                        }
                        
                        Spacer()
                    }
                    .ignoresSafeArea(.keyboard)
                    .padding()
                }
                .navigationBarHidden(true)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Log in error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
}
