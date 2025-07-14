//
//  WelcomeViewController.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/27/25.
//

import Foundation
import CoreData
//
//class AuthViewModel {
//    private let context = CoreDataManager.shared.context
//
//    func validateLogin(username: String, password: String) -> Bool {
//        guard !username.isEmpty, !password.isEmpty else {
//            return false
//        }
//
//        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)
//
//        do {
//            let users = try context.fetch(fetchRequest)
//            return !users.isEmpty
//        } catch {
//            print("❌ Error validating login: \(error)")
//            return false
//        }
//    }
//    
//    func doesThisUserExist(username: String) -> Bool {
//        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "username == %@", username)
//        
//        do {
//            let users = try context.fetch(fetchRequest)
//            return !users.isEmpty
//        } catch {
//            print("❌ Error validating login: \(error)")
//            return false
//        }
//    }
//}
