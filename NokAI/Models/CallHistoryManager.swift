//
//  CallHistoryManager.swift
//  NokAI
//
//  Created by Charlotte Lew on 7/13/25.
//

import Foundation


struct CallRecord: Decodable, Identifiable {
    let id = UUID()
    let with: String
    let timestamp: Date
    let duration: TimeInterval

    enum CodingKeys: String, CodingKey {
        case with, timestamp, duration
    }
}



class CallHistoryManager: ObservableObject {
    @Published var callHistory: [CallRecord] = []
    var currentUsername: String
    private let baseURL = "http://yourIP:3000" // or your IP on device

    init (currentUsername: String) {
        self.currentUsername = currentUsername
        
    }
    
    func fetchCallHistory(completion: @escaping ([CallRecord]) -> Void) {
        guard let url = URL(string: "\(baseURL)/calls/\(currentUsername)") else {
            print("❌ Invalid URL: \(baseURL)/calls/\(currentUsername)")
            completion([])
            return
        }
        print("currUsername", currentUsername)
        print("🌐 Fetching call history from: \(url)")

        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        decoder.dateDecodingStrategy = .formatted(formatter)

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Failed to fetch call history:", error)
                completion([])
                return
            }

            guard let data = data else {
                print("❌ No data received from server")
                completion([])
                return
            }

            // Print raw JSON for inspection
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Raw JSON received:\n\(jsonString)")
            }

            do {
                let records = try decoder.decode([CallRecord].self, from: data)
                print("✅ Successfully decoded \(records.count) call history records")
                DispatchQueue.main.async {
                    completion(records)
                }
            } catch {
                print("❌ Decoding error:", error)
                completion([])
            }
        }.resume()
    }



    
    func logCall(to peer: String, duration: TimeInterval) {
        let url = URL(string: "\(baseURL)/calls/add")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "from": currentUsername,
            "to": peer,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "duration": Int(duration)
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Failed to log call:", error)
            } else {
                print("📞 Call logged successfully")
            }
        }.resume()
    }

}

