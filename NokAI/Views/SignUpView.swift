//
//  SignUpViewController.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//

import SwiftUI

struct SignupView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var passwordAgain: String = ""
    @State private var name: String = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var isSignedUp = false
    
    let authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack {
                    TextField("Username", text: $username)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 240, height: 30)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(5)
                    TextField("Name", text: $name)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 240, height: 30)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(5)

                    SecureField("Password", text: $password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 240, height: 30)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(5)
                    SecureField("Confirm your password", text: $passwordAgain)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 240, height: 30)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(5)
                }
                Button(action: {
                    if username.isEmpty || password.isEmpty || passwordAgain.isEmpty || name.isEmpty {
                        alertMessage = "Please fill out all fields"
                        showAlert = true
                    } else if password != passwordAgain {
                        alertMessage = "Passwords do not match"
                        showAlert = true
                    } else if !authViewModel.doesThisUserExist(username: username) {
                        UserDataManager.shared.createUser(username: username, password: password, name: name)
                            UserDefaults.standard.set(username, forKey: "currentUsername")
                            isSignedUp = true
                    } else if authViewModel.doesThisUserExist(username: username){
                        alertMessage = "this username is already in use"
                        showAlert = true
                    }
                }) {
                    Text("Sign Up")
                        .font(.custom("VT323", size: 18))
                        .foregroundColor(.black)
                        .frame(width: 120, height: 36)
                        .background(Color(red: 0.9, green: 1, blue: 0.3))
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black, lineWidth: 1))
                }
                
                Spacer()
                
            }
            .background(
            NavigationLink(destination: HomeView(), isActive: $isSignedUp) {
                    EmptyView()
                }
            )
        }
    }
}
