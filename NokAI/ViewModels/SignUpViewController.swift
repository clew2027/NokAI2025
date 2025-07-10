//
//  SignUpViewController.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//

import UIKit
import SwiftUI

class SignupViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSubviews()
        layoutSubviews()
    }
    
    private let titleLabel = UILabel()
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let passwordFieldAgain = UITextField()
    private let nameField = UITextField()

    private let signUpButton = UIButton(type: .system)
    private let context = CoreDataManager.shared.ViewContext()


  private func setupSubviews() {
    titleLabel.text = "Sign Up"
    titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
    titleLabel.textAlignment = .center

    usernameField.placeholder = "Enter your username"
    usernameField.borderStyle = .roundedRect
      
      passwordField.placeholder = "Enter your password"
      passwordField.borderStyle = .roundedRect
      
      passwordFieldAgain.placeholder = "Enter your password again"
      passwordFieldAgain.borderStyle = .roundedRect

    signUpButton.setTitle("Sign Up", for: .normal)
    signUpButton.addTarget(self,
                           action: #selector(signUpTapped),
                           for: .touchUpInside)
      nameField.placeholder = "Enter your name"
      nameField.borderStyle = .roundedRect
      
    [titleLabel, usernameField, signUpButton, passwordField, passwordFieldAgain, nameField].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview($0)
    }
  }

    private func layoutSubviews() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            usernameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            usernameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            usernameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            usernameField.heightAnchor.constraint(equalToConstant: 44),

            passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 20),
            passwordField.leadingAnchor.constraint(equalTo: usernameField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: usernameField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 44),

            passwordFieldAgain.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
            passwordFieldAgain.leadingAnchor.constraint(equalTo: usernameField.leadingAnchor),
            passwordFieldAgain.trailingAnchor.constraint(equalTo: usernameField.trailingAnchor),
            passwordFieldAgain.heightAnchor.constraint(equalToConstant: 44),

            nameField.topAnchor.constraint(equalTo: passwordFieldAgain.bottomAnchor, constant: 20),
            nameField.leadingAnchor.constraint(equalTo: usernameField.leadingAnchor),
            nameField.trailingAnchor.constraint(equalTo: usernameField.trailingAnchor),
            nameField.heightAnchor.constraint(equalToConstant: 44),

            signUpButton.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 20),
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }


    
    @objc func signUpTapped() {
        guard let name = nameField.text, let username = usernameField.text, let password = passwordField.text, let passwordAgain = passwordFieldAgain.text, !password.isEmpty, !passwordAgain.isEmpty, !username.isEmpty else {let alert = UIAlertController(title: "oops",
                                                                                                                                                                    message: "Please enter  valid username and password",
                                                                                                                                                                    preferredStyle: .alert)
                                                                                                                                      alert.addAction(.init(title: "OK", style: .default))
                                                                                                                                      present(alert, animated: true)
                                                                                                                                      return
        }
        if password != passwordAgain {
            let alert = UIAlertController(title: "passwords dont match",
                                          message: "passwords dont match",
                                          preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            present(alert, animated: true)
            return
                }
        UserDataManager.shared.createUser(username: username, password: password, name: name)
        let hostingController = UIHostingController(rootView: CallContainerView())
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
}
