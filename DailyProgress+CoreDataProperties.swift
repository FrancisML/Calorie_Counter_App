//
//  DailyProgress+CoreDataProperties.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/15/25.
//
//

import Foundation
import CoreData


extension DailyProgress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyProgress> {
        return NSFetchRequest<DailyProgress>(entityName: "DailyProgress")
    }

    @NSManaged public var dailyLimit: Int32
    @NSManaged public var dailyWeight: Int32
    @NSManaged public var date: Date?
    @NSManaged public var dayNumber: Int32
    @NSManaged public var passOrFail: String?
    @NSManaged public var calorieIntake: Int32
    @NSManaged public var ledgerEntries: NSSet?
    @NSManaged public var userProfile: UserProfile?

}

// MARK: Generated accessors for ledgerEntries
extension DailyProgress {

    @objc(addLedgerEntriesObject:)
    @NSManaged public func addToLedgerEntries(_ value: LedgerEntry)

    @objc(removeLedgerEntriesObject:)
    @NSManaged public func removeFromLedgerEntries(_ value: LedgerEntry)

    @objc(addLedgerEntries:)
    @NSManaged public func addToLedgerEntries(_ values: NSSet)

    @objc(removeLedgerEntries:)
    @NSManaged public func removeFromLedgerEntries(_ values: NSSet)

}

extension DailyProgress : Identifiable {

}
