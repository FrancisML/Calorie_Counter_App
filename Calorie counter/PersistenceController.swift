//
//  PersistenceController.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/12/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        // Ensure this matches your .xcdatamodeld file name
        container = NSPersistentContainer(name: "CalorieCounterModel")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // Log and handle error in a user-friendly way
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("Core Data stack initialized successfully at: \(description.url?.absoluteString ?? "Unknown Location")")
            }
        }

        // Configure the viewContext for better performance
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.undoManager = nil // Improves performance for write-heavy operations
    }

    /// Returns the main context for the app
    var context: NSManagedObjectContext {
        container.viewContext
    }

    /// Saves the context, with error handling
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Changes saved successfully!")
            } catch {
                let nsError = error as NSError
                print("Failed to save context: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    /// Fetches all entities of a given type
    func fetch<T: NSManagedObject>(_ entity: T.Type, with sortDescriptors: [NSSortDescriptor] = []) -> [T] {
        let request = T.fetchRequest()
        request.sortDescriptors = sortDescriptors

        do {
            return try container.viewContext.fetch(request) as? [T] ?? []
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }

    /// Deletes all objects of a given entity
    func deleteAll<T: NSManagedObject>(_ entity: T.Type) {
        let request = T.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try container.viewContext.execute(batchDeleteRequest)
            print("All \(entity) objects deleted successfully!")
        } catch {
            print("Failed to delete \(entity): \(error)")
        }
    }
}
