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
        container = NSPersistentContainer(name: "CalorieCounterModel") // Use your model's name here
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }
}
