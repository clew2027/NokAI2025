//
//  WelcomeViewController.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/27/25.
//

import UIKit
import CoreData

class WelcomeViewController: UIViewController {
    private let titleLabel = UILabel()
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let signUpButton = UIButton(type: .system)
    private let logInButton = UIButton(type: .system)
    private let context = CoreDataManager.shared.ViewContext()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupSubviews()
    layoutSubviews()
  }

func setupSubviews() {
    titleLabel.text = "Welcome to NokAI june 30 1 pm"
    titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
    titleLabel.textAlignment = .center

    usernameField.placeholder = "Enter your username"
    usernameField.borderStyle = .roundedRect
      
      passwordField.placeholder = "Enter your password"
      passwordField.borderStyle = .roundedRect

    signUpButton.setTitle("Sign Up", for: .normal)
    signUpButton.addTarget(self,
                           action: #selector(signUpTapped),
                           for: .touchUpInside)
      
      logInButton.setTitle("Log In", for: .normal)
      logInButton.addTarget(self,
                            action: #selector(logInTapped),
                            for: .touchUpInside)

    [titleLabel, usernameField, signUpButton, passwordField, logInButton].forEach {
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
      passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
      passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
      passwordField.heightAnchor.constraint(equalToConstant: 44),

      signUpButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
      signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

      logInButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 10),
      logInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)

    ])
  }

  @objc private func signUpTapped() {
      let signupVC = SignupViewController()
          present(signupVC, animated: true)
  }
    @objc private func logInTapped() {
        guard let username = usernameField.text, !username.isEmpty, let password = passwordField.text, !password.isEmpty else {
        let alert = UIAlertController(title: "Oops",
                                      message: "Please enter a username and password",
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
        return
      }
    
        if validateLogin(username: username, password: password) {
            let mainVC = ViewController()
            mainVC.modalPresentationStyle = .fullScreen
            present(mainVC, animated: true)
        } else {
            let alert = UIAlertController(title: "Wrong Credentials",
                                          message: "Please valid username and password",
                                          preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
    }
    
    func validateLogin(username: String, password: String) -> Bool {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)
        
        do {
            let users = try context.fetch(fetchRequest)
            return !users.isEmpty
        } catch {
            print("❌ Error validating login: \(error)")
            return false
        }
    }

}
