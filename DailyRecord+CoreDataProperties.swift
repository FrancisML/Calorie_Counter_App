//
//  DailyRecord+CoreDataProperties.swift
//  Calorie counter
//
//  Created by frank lasalvia on 3/11/25.
//
//

import Foundation
import CoreData


extension DailyRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyRecord> {
        return NSFetchRequest<DailyRecord>(entityName: "DailyRecord")
    }

    @NSManaged public var calorieGoal: Double
    @NSManaged public var calorieIntake: Double
    @NSManaged public var date: Date?
    @NSManaged public var passFail: Bool
    @NSManaged public var waterGoal: Double
    @NSManaged public var waterIntake: Double
    @NSManaged public var waterUnit: String?
    @NSManaged public var weighIn: Double
    @NSManaged public var diaryEntries: NSSet?
    @NSManaged public var weighIns: NSSet?
    @NSManaged public var workoutEntries: NSSet?

}

// MARK: Generated accessors for diaryEntries
extension DailyRecord {

    @objc(addDiaryEntriesObject:)
    @NSManaged public func addToDiaryEntries(_ value: CoreDiaryEntry)

    @objc(removeDiaryEntriesObject:)
    @NSManaged public func removeFromDiaryEntries(_ value: CoreDiaryEntry)

    @objc(addDiaryEntries:)
    @NSManaged public func addToDiaryEntries(_ values: NSSet)

    @objc(removeDiaryEntries:)
    @NSManaged public func removeFromDiaryEntries(_ values: NSSet)

}

// MARK: Generated accessors for weighIns
extension DailyRecord {

    @objc(addWeighInsObject:)
    @NSManaged public func addToWeighIns(_ value: WeighInEntry)

    @objc(removeWeighInsObject:)
    @NSManaged public func removeFromWeighIns(_ value: WeighInEntry)

    @objc(addWeighIns:)
    @NSManaged public func addToWeighIns(_ values: NSSet)

    @objc(removeWeighIns:)
    @NSManaged public func removeFromWeighIns(_ values: NSSet)

}

// MARK: Generated accessors for workoutEntries
extension DailyRecord {

    @objc(addWorkoutEntriesObject:)
    @NSManaged public func addToWorkoutEntries(_ value: WorkoutEntry)

    @objc(removeWorkoutEntriesObject:)
    @NSManaged public func removeFromWorkoutEntries(_ value: WorkoutEntry)

    @objc(addWorkoutEntries:)
    @NSManaged public func addToWorkoutEntries(_ values: NSSet)

    @objc(removeWorkoutEntries:)
    @NSManaged public func removeFromWorkoutEntries(_ values: NSSet)

}

extension DailyRecord : Identifiable {

}
