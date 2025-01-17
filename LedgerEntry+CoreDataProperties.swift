//
//  LedgerEntry+CoreDataProperties.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/15/25.
//
//

import Foundation
import CoreData


extension LedgerEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LedgerEntry> {
        return NSFetchRequest<LedgerEntry>(entityName: "LedgerEntry")
    }

    @NSManaged public var calories: Int32
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var dailyProgress: DailyProgress?

}

extension LedgerEntry : Identifiable {

}
