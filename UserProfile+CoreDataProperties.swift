//
//  UserProfile+CoreDataProperties.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/13/25.
//
//

import Foundation
import CoreData


extension UserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }

    @NSManaged public var activityLevel: String?
    @NSManaged public var age: Int32
    @NSManaged public var calorieDeficit: Int32
    @NSManaged public var dailyCalorieGoal: Int32
    @NSManaged public var dailyLimit: Int32
    @NSManaged public var daysLeft: Int32
    @NSManaged public var gender: String?
    @NSManaged public var goalCalories: Int32
    @NSManaged public var goalMass: Double
    @NSManaged public var goalWeight: Int32
    @NSManaged public var heightCm: Int32
    @NSManaged public var heightFt: Int32
    @NSManaged public var heightIn: Int32
    @NSManaged public var name: String?
    @NSManaged public var profilePicture: Data?
    @NSManaged public var startDate: Date?
    @NSManaged public var startPicture: Data?
    @NSManaged public var targetDate: Date?
    @NSManaged public var useMetric: Bool
    @NSManaged public var userBMR: Int32
    @NSManaged public var weight: Int32
    @NSManaged public var lastSavedDate: Date?

}

extension UserProfile : Identifiable {

}
