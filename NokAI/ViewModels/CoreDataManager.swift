//
//  PersistenceController.swift
//  NokAI
//
//  Created by Charlotte Lew on 6/28/25.
//


import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    private init() {
        persistentContainer = NSPersistentContainer(name: "CoreData")

        // Enable lightweight migration
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true

        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Failed to load Core Data store: \(error)")
            }
        }
    }

    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data context: \(error)")
            }
        }
    }
    
    func ViewContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
