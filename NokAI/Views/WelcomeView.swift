//
//  WelcomeView.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/27/25.
//
import UIKit



class WelcomeViewController: UIViewController {
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "background").ignoresSafeAreaEdges)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to"
        label.font = UIFont(name: "VT323", size: 24)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "NokAI"
        label.font = UIFont(name: "VT323", size: 40)
        label.textColor = UIColor(red: 0.9, green: 1, blue: 0.3, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let usernameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Username"
        field.font = UIFont(name: "VT323", size: 16)
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.textColor = .white
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.font = UIFont(name: "VT323", size: 16)
        field.borderStyle = .none
        field.isSecureTextEntry = true
        field.backgroundColor = .clear
        field.textColor = .white
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor(red: 0.9, green: 1, blue: 0.3, alpha: 1)
        button.titleLabel?.font = UIFont(name: "VT323", size: 18)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let signupLabel: UILabel = {
        let label = UILabel()
        let text = NSMutableAttributedString(string: "New here? ",
                                             attributes: [.font: UIFont(name: "Courier", size: 14)!,
                                                          .foregroundColor: UIColor.white])
        let link = NSAttributedString(string: "Sign Up",
                                      attributes: [.font: UIFont(name: "Courier-Bold", size: 14)!,
                                                   .foregroundColor: UIColor.black])
        text.append(link)
        label.attributedText = text
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let authViewModel = AuthViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundImageView)
        [titleLabel, appNameLabel, usernameField, passwordField, loginButton, signupLabel].forEach {
            view.addSubview($0)
        }

        loginButton.addTarget(self, action: #selector(logInTapped), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(signUpTapped))
        signupLabel.addGestureRecognizer(tap)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            appNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            appNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            usernameField.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 60),
            usernameField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameField.widthAnchor.constraint(equalToConstant: 240),
            usernameField.heightAnchor.constraint(equalToConstant: 30),

            passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 20),
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordField.widthAnchor.constraint(equalTo: usernameField.widthAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 30),

            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 30),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 120),
            loginButton.heightAnchor.constraint(equalToConstant: 36),

            signupLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12),
            signupLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func signUpTapped() {
        let signupVC = SignupViewController()
        present(signupVC, animated: true)
    }

    @objc private func logInTapped() {
        guard let username = usernameField.text,
              let password = passwordField.text,
              !username.isEmpty, !password.isEmpty else {
            showAlert(title: "Oops", message: "Please enter a username and password")
            return
        }

        if authViewModel.validateLogin(username: username, password: password) {
            UserDefaults.standard.set(username, forKey: "currentUsername")
            let mainVC = HomeViewController()
            mainVC.modalPresentationStyle = .fullScreen
            present(mainVC, animated: true)
        } else {
            showAlert(title: "Wrong Credentials", message: "Please enter valid username and password")
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
