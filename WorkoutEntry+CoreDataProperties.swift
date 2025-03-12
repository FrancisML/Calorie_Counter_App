//
//  WorkoutEntry+CoreDataProperties.swift
//  Calorie counter
//
//  Created by frank lasalvia on 3/11/25.
//
//

import Foundation
import CoreData


extension WorkoutEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutEntry> {
        return NSFetchRequest<WorkoutEntry>(entityName: "WorkoutEntry")
    }

    @NSManaged public var name: String?
    @NSManaged public var duration: Double
    @NSManaged public var caloriesBurned: Double
    @NSManaged public var time: String?
    @NSManaged public var imageName: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var dailyRecord: DailyRecord?

}

extension WorkoutEntry : Identifiable {

}
