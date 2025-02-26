//
//  DailyRecord+CoreDataProperties.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/25/25.
//
//

import Foundation
import CoreData


extension DailyRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyRecord> {
        return NSFetchRequest<DailyRecord>(entityName: "DailyRecord")
    }

    @NSManaged public var date: Date?
    @NSManaged public var calorieIntake: Double
    @NSManaged public var waterIntake: Double
    @NSManaged public var waterUnit: String?
    @NSManaged public var passFail: Bool
    @NSManaged public var waterGoal: Double
    @NSManaged public var diaryEntries: NSSet?

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

extension DailyRecord : Identifiable {

}
