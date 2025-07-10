//
//  FriendRequestCell.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//

import UIKit

class FriendRequestCell: UITableViewCell {
    let usernameLabel = UILabel()
    let acceptButton = UIButton(type: .system)
    let declineButton = UIButton(type: .system)

    var onAccept: (() -> Void)?
    var onDecline: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        declineButton.translatesAutoresizingMaskIntoConstraints = false

        acceptButton.setTitle("Accept", for: .normal)
        declineButton.setTitle("Decline", for: .normal)

        acceptButton.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(handleDecline), for: .touchUpInside)

        contentView.addSubview(usernameLabel)
        contentView.addSubview(acceptButton)
        contentView.addSubview(declineButton)

        NSLayoutConstraint.activate([
            usernameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            declineButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            declineButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            acceptButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            acceptButton.trailingAnchor.constraint(equalTo: declineButton.leadingAnchor, constant: -12),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handleAccept() {
        onAccept?()
    }

    @objc private func handleDecline() {
        onDecline?()
    }
}
