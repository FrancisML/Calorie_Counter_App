//
//  DailyProgressPersistenceController.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/13/25.
//

import CoreData

struct DailyProgressPersistenceController {
    static let shared = DailyProgressPersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "DailyProgress")
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

