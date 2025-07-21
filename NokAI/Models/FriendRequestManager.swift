//
//  FriendRequestManager.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/30/25.
//

import Foundation
import UIKit

class FriendRequestManager {
    static let shared = FriendRequestManager()
    private let baseURL = "http://yourIP:3000" // change to your IP if needed

    private init() {}

    // MARK: - Send Friend Request
    func sendRequest(from: String, to: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/friend-requests/send") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["fromUsername": from, "toUsername": to]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 201
            DispatchQueue.main.async {
                completion(success)
            }
        }.resume()
    }

    // MARK: - Fetch Outgoing Requests
    func fetchOutgoingRequests(from username: String, completion: @escaping ([[String: Any]]) -> Void) {
        guard let url = URL(string: "\(baseURL)/friend-requests/outgoing/\(username)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let result = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }

    // MARK: - Fetch Incoming Requests
    func fetchIncomingRequests(for username: String, completion: @escaping ([[String: Any]]) -> Void) {
        guard let url = URL(string: "\(baseURL)/friend-requests/incoming/\(username)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let result = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }.resume()
    }

    // MARK: - Accept Friend Request
    func acceptRequest(from: String, to: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/friend-requests/accept") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["from": from, "to": to]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async {
                completion(success)
            }
        }.resume()
    }

    // MARK: - Decline Friend Request
    func declineRequest(from: String, to: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/friend-requests/decline") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["from": from, "to": to]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async {
                completion(success)
            }
        }.resume()
    }
}
