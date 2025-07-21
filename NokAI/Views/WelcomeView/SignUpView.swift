//
//  SignUpView.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//

import SwiftUI

struct SignupView: View {
    @Binding var isPresented: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var passwordAgain: String = ""
    @State private var name: String = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var isSignedUp = false
    @State private var selectedImage = UIImage(systemName: "person.crop.circle.fill")!
    @State private var showImagePicker = false

    
    var body: some View {
        Group {
            if isSignedUp {
                HomeView()
            } else {
                signupForm
            }
        }
    }
    
    var signupForm: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Button(action: {
                    isPresented = false
                    print("trying to go back")
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.custom("VT323-Regular", size: 24))
                    .foregroundColor(Color("AccentGreen"))
                }
                .padding(.top, -150)
                .padding(.leading, -170)
                Text("Let's get started")
                    .font(.custom("VT323", size: 48))
                    .foregroundColor(Color("AccentGreen"))
                    .padding(.top, -30)
                
                Button(action: {
                }) {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("AccentGreen"), lineWidth: 2))
                }
                .padding(.bottom, 16)
                
                CustomTextField(text: $username, placeholder: "Username")
                CustomTextField(text: $name, placeholder: "Name")
                CustomSecureField(text: $password, placeholder: "Password")
                CustomSecureField(text: $passwordAgain, placeholder: "Re-enter Password")

                Button(action: handleSignUp) {
                    Text("Sign Up")
                        .font(.custom("VT323", size: 22))
                        .foregroundColor(Color("AccentGreen"))
                        .frame(width: 120, height: 36)
                        .background(Color("AccentPurple").opacity(0.9))
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color("AccentGreen"), lineWidth: 1))
                }
                .padding(.top, 60)
            }
            .padding(.horizontal, 30)
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func handleSignUp() {
        if username.isEmpty || password.isEmpty || passwordAgain.isEmpty || name.isEmpty {
            alertMessage = "Please fill out all fields"
            showAlert = true
        } else if password != passwordAgain {
            alertMessage = "Passwords do not match"
            showAlert = true
        }
        
        UserDataManager.shared.doesThisUserExist(username: username) { exists in
            if !exists {
                UserDataManager.shared.createUser(username: username, password: password, name: name, profileImage: selectedImage) { success in
                    if success {
                        UserDefaults.standard.set(username, forKey: "currentUsername")
                        isSignedUp = true
                        print("✅ Signed up new user:", username)
                        print("📍 reached line 112 SignupView")
                    } else {
                        alertMessage = "Signup failed"
                        showAlert = true
                    }
                }
            } else {
                alertMessage = "This username is already in use"
                showAlert = true
            }
        }

    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
