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
        container = NSPersistentContainer(name: "CalorieCounterModel")
        
        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        description?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)

        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                print("❌ Failed to load persistent store: \(error), \(error.userInfo)")
            } else {
                print("✅ Core Data stack initialized at: \(description.url?.absoluteString ?? "Unknown Location")")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.undoManager = nil

        preloadActivitiesIfNeeded()
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Changes saved successfully!")
            } catch {
                let nsError = error as NSError
                print("❌ Failed to save context: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func fetch<T: NSManagedObject>(_ entity: T.Type, with sortDescriptors: [NSSortDescriptor] = []) -> [T] {
        let request = T.fetchRequest()
        request.sortDescriptors = sortDescriptors

        do {
            return try container.viewContext.fetch(request) as? [T] ?? []
        } catch {
            print("❌ Fetch error: \(error)")
            return []
        }
    }

    func deleteAll<T: NSManagedObject>(_ entity: T.Type) {
        let request = T.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try container.viewContext.execute(batchDeleteRequest)
            print("🗑️ All \(entity) objects deleted successfully!")
        } catch {
            print("❌ Failed to delete \(entity): \(error)")
        }
    }

    private func preloadActivitiesIfNeeded() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<ActivityModel> = ActivityModel.fetchRequest()

        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                let activities = [
                    ("Abs", 2.8, "ABS"),
                    ("Badminton", 4.5, "ShuttleCock"),
                    ("Baseball", 5.0, "Baseball"),
                    ("Basketball", 6.5, "Basketball"),
                    ("Boxing", 12.0, "Boxing"),
                    ("Calisthenics", 8.0, "calisthenics"),
                    (" VICross-Country Skiing", 9.0, "XSkiing"),
                    ("Cycling", 8.0, "Bikeing"),
                    ("Elliptical", 5.0, "Eliptical"),
                    ("Golf", 4.3, "Golf"),
                    ("Hiking", 6.5, "Hiking"),
                    ("Hockey", 8.0, "Hockey"),
                    ("Jogging", 7.0, "Running"),
                    ("Mountain Biking", 8.5, "MountainBike"),
                    ("Paddle Boarding", 4.0, "Paddle"),
                    ("Pickleball", 4.1, "Pickle"),
                    ("Pilates", 3.0, "Pilates"),
                    ("Racquetball", 7.0, "racquetball"),
                    ("Rock Climbing", 9.0, "Rockclimbing"),
                    ("Rowing", 7.0, "Rowing"),
                    ("Running", 9.8, "Running"),
                    ("Scuba Diving", 7.0, "scuba"),
                    ("Skiing", 7.0, "Skiing"),
                    ("Snowboarding", 5.0, "Snowboarding"),
                    ("Soccer", 7.0, "Soccer"),
                    ("Spinning", 8.5 "Spining"),
                    ("Squash", 7.3, "racquetball"),
                    ("Swimming", 8.3, "Swiming"),
                    ("Tennis", 7.3, "tennis"),
                    ("Volleyball", 3.5, "volley"),
                    ("Walking", 3.8, "Walking"),
                    ("Weight Training", 6.0, "Weights"),
                    ("Yoga", 2.5, "Yoga"),
                    ("Zumba", 5.5, "Zumba"),
                    ("Cleaning", 3.5, "cleaning"),
                    ("Gardening", 3.8, "Garden"),
                    ("Mowing Lawn", 5.5, "mowing"),
                    ("Shoveling Snow", 6.0, "snow"),
                    ("Cleaning Windows", 3.2, "Cleaningwindows"),
                    ("Painting", 4.5, "Paint"),
                    ("Shopping", 2.3, "Shop"),
                    ("Childcare", 3.0, "Child"),
                    ("Standing", 2.5, "BMDefault"),
                    ("Construction Work", 4.0, "Const"),
                    ("Carpentry", 6.0, "Carpentery"),
                    ("Nursing", 3.3, "nurse"),
                    ("Teaching", 2.8, "Teach"),
                    ("Moving Furniture", 6.0, "Moving"),
                    ("Rucking", 7.0, "Rucking"),
                    ("Sprinting", 14.0, "Sprinting"),
                    ("Treading Water", 3.5, "Swiming"),
                    ("Table Tennis", 4.0, "PingPong"),
                    ("Martial Arts", 10.0, "MartialArts"),
                    ("Stretching", 2.5, "Stretch"),
                    ("Aerobics", 5.0, "Zumba"),
                    ("Jump Rope", 8.8, "jumpRope"),
                    ("Dancing", 3.0, "Zumba"),
                    ("Fishing", 3.5, "Fish"),
                    ("Horseback Riding", 5.8, "Horse"),
                    ("Skating", 7.0, "Skateing"),
                    ("Ice Skating", 7.0, "IceSkateing"),
                    ("Kayaking", 5.0, "Kayak"),
                    ("Canoeing", 3.0, "Kayak"),
                    ("Playing Video Games", 3.8, "vgame")
                ]

                for (name, metValue, imageName) in activities {
                    let newActivity = ActivityModel(context: context)
                    newActivity.id = UUID()
                    newActivity.name = name
                    newActivity.metValue = metValue
                    newActivity.imageName = imageName
                }

                try context.save()
                print("✅ Activities preloaded successfully!")
            }
        } catch {
            print("❌ ERROR: Failed to preload activities: \(error.localizedDescription)")
        }
    }
}
