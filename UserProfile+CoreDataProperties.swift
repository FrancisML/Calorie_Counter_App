//
//  UserProfile+CoreDataProperties.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/26/25.
//
//

import Foundation
import CoreData


extension UserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }

    @NSManaged public var activityInt: Int32
    @NSManaged public var age: Int32
    @NSManaged public var birthdate: Date?
    @NSManaged public var calorieDeficit: Int32
    @NSManaged public var currentWeight: Double
    @NSManaged public var customCals: Int32
    @NSManaged public var dailyCalorieDif: Int32
    @NSManaged public var dailyCalorieGoal: Int32
    @NSManaged public var dailyLimit: Int32
    @NSManaged public var daysLeft: Int32
    @NSManaged public var gender: String?
    @NSManaged public var goalCalories: Int32
    @NSManaged public var goalId: Int32
    @NSManaged public var goalWeight: Double
    @NSManaged public var heightCm: Int32
    @NSManaged public var heightFt: Int32
    @NSManaged public var heightIn: Int32
    @NSManaged public var lastSavedDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var profilePicture: Data?
    @NSManaged public var startDate: Date?
    @NSManaged public var startPicture: Data?
    @NSManaged public var startWeight: Double
    @NSManaged public var targetDate: Date?
    @NSManaged public var tempDayNumber: Int32
    @NSManaged public var useMetric: Bool
    @NSManaged public var userBMR: Int32
    @NSManaged public var waterGoal: Double
    @NSManaged public var waterUnit: String?
    @NSManaged public var weekGoal: Double
    @NSManaged public var weightDifference: Double
    @NSManaged public var progressPicture: NSSet?
    @NSManaged public var bodyMeasurement: NSSet?

}

// MARK: Generated accessors for progressPicture
extension UserProfile {

    @objc(addProgressPictureObject:)
    @NSManaged public func addToProgressPicture(_ value: ProgressPicture)

    @objc(removeProgressPictureObject:)
    @NSManaged public func removeFromProgressPicture(_ value: ProgressPicture)

    @objc(addProgressPicture:)
    @NSManaged public func addToProgressPicture(_ values: NSSet)

    @objc(removeProgressPicture:)
    @NSManaged public func removeFromProgressPicture(_ values: NSSet)

}

// MARK: Generated accessors for bodyMeasurement
extension UserProfile {

    @objc(addBodyMeasurementObject:)
    @NSManaged public func addToBodyMeasurement(_ value: BodyMeasurement)

    @objc(removeBodyMeasurementObject:)
    @NSManaged public func removeFromBodyMeasurement(_ value: BodyMeasurement)

    @objc(addBodyMeasurement:)
    @NSManaged public func addToBodyMeasurement(_ values: NSSet)

    @objc(removeBodyMeasurement:)
    @NSManaged public func removeFromBodyMeasurement(_ values: NSSet)

}

extension UserProfile : Identifiable {

}
