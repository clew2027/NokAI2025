//
//  UserModels.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/28/25.
//
import Foundation
import UIKit

class UserDataManager {
    static let shared = UserDataManager()
    private let baseURL = "http://yourIP:3000"

    private init() {}

    public func extractBase64Data(from dataURL: String) -> String? {
        guard let commaIndex = dataURL.firstIndex(of: ",") else { return nil }
        return String(dataURL[dataURL.index(after: commaIndex)...])
    }

    // MARK: - Create User
    func createUser(username: String, password: String, name: String, profileImage: UIImage?, completion: @escaping (Bool) -> Void) {
        print("got to userdatamanager createUser")
        let url = URL(string: "\(baseURL)/users/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let base64 = profileImage?.jpegData(compressionQuality: 0.8)?.base64EncodedString() ?? ""
        let profilePhoto = "data:image/jpeg;base64,\(base64)"

        let body: [String: Any] = [
            "username": username,
            "password": password,
            "name": name,
            "profilePhoto": profilePhoto
        ]
        print(body)
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("📤 Creating user: \(username)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ createUser error: \(error.localizedDescription)")
            }

            let status = (response as? HTTPURLResponse)?.statusCode
            print("✅ createUser response status: \(status ?? -1)")

            let success = status == 201
            DispatchQueue.main.async {
                completion(success)
            }
        }.resume()
    }

    // MARK: - Fetch User
    func fetchUser(byUsername username: String, completion: @escaping ([String: Any]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/\(username)") else { return }

        print("📤 Fetching user: \(username)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ fetchUser error: \(error.localizedDescription)")
            }

            let status = (response as? HTTPURLResponse)?.statusCode
            print("✅ fetchUser response status: \(status ?? -1)")

            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    completion(json)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }

    // MARK: - Add Friend
    func addFriend(userA: String, userB: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/friends/add") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["userA": userA, "userB": userB]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        print("📤 Adding friend: \(userA) ↔️ \(userB)")

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ addFriend error: \(error.localizedDescription)")
            }

            let status = (response as? HTTPURLResponse)?.statusCode
            print("✅ addFriend response status: \(status ?? -1)")

            let success = status == 200
            DispatchQueue.main.async {
                completion(success)
            }
        }.resume()
    }

    // MARK: - List Friends
    func listFriends(ofUsername username: String, completion: @escaping ([String]) -> Void) {
        guard let url = URL(string: "\(baseURL)/friends/\(username)") else { return }

        print("📤 Listing friends for: \(username)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ listFriends error: \(error.localizedDescription)")
            }

            let status = (response as? HTTPURLResponse)?.statusCode
            print("✅ listFriends response status: \(status ?? -1)")

            if let data = data,
               let list = try? JSONDecoder().decode([String].self, from: data) {
                DispatchQueue.main.async {
                    completion(list)
                }
            } else {
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }

    // MARK: - Remove Friend
    func removeFriend(userA: String, userB: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/friends/remove") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["userA": userA, "userB": userB]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        print("📤 Removing friend: \(userA) ❌ \(userB)")

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ removeFriend error: \(error.localizedDescription)")
            }

            let status = (response as? HTTPURLResponse)?.statusCode
            print("✅ removeFriend response status: \(status ?? -1)")

            let success = status == 200
            DispatchQueue.main.async {
                completion(success)
            }
        }.resume()
    }
    
    func validateLogin(username: String, password: String, completion: @escaping (Bool) -> Void) {
            guard !username.isEmpty, !password.isEmpty else {
                completion(false)
                return
            }

            guard let url = URL(string: "\(baseURL)/users/login") else {
                completion(false)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body = ["username": username, "password": password]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            print("🔐 Validating login for username: \(username)")

            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    print("❌ validateLogin error: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(false) }
                    return
                }

                let success = (response as? HTTPURLResponse)?.statusCode == 200
                print(success ? "✅ Login successful" : "❌ Login failed")
                DispatchQueue.main.async { completion(success) }
            }.resume()
        }

        // MARK: - Does This User Exist
        func doesThisUserExist(username: String, completion: @escaping (Bool) -> Void) {
            guard let url = URL(string: "\(baseURL)/users/\(username)/exists") else {
                completion(false)
                return
            }

            print("🔍 Checking if user exists: \(username)")

            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("❌ doesThisUserExist error: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(false) }
                    return
                }

                guard let data = data,
                      let result = try? JSONSerialization.jsonObject(with: data) as? [String: Bool],
                      let exists = result["exists"] else {
                    print("⚠️ Unexpected response from /exists check")
                    DispatchQueue.main.async { completion(false) }
                    return
                }

                print(exists ? "✅ User exists" : "❌ User does not exist")
                DispatchQueue.main.async { completion(exists) }
            }.resume()
        }
    public func performSearch(query: String, completion: @escaping ([UserSearchResult]) -> Void) {
        guard !query.isEmpty,
              let currentUsername = UserDefaults.standard.string(forKey: "currentUsername"),
              let url = URL(string: "\(baseURL)/users/search?q=\(query)") else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Search error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            guard let data = data,
                  let results = try? JSONDecoder().decode([UserSearchResult].self, from: data) else {
                print("⚠️ Failed to decode search results")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            let filtered = results.filter { $0.username != currentUsername }

            DispatchQueue.main.async {
                completion(filtered)
            }
        }.resume()
    }
}
