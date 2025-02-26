//
//  CoreDiaryEntry+CoreDataProperties.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/25/25.
//
//

import Foundation
import CoreData


extension CoreDiaryEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDiaryEntry> {
        return NSFetchRequest<CoreDiaryEntry>(entityName: "CoreDiaryEntry")
    }

    @NSManaged public var time: String?
    @NSManaged public var iconName: String?
    @NSManaged public var entryDescription: String?
    @NSManaged public var detail: String?
    @NSManaged public var calories: Int32
    @NSManaged public var type: String?
    @NSManaged public var imageName: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var fats: Double
    @NSManaged public var carbs: Double
    @NSManaged public var protein: Double
    @NSManaged public var dailyRecord: DailyRecord?

}

extension CoreDiaryEntry : Identifiable {

}
