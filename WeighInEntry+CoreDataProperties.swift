//
//  WeighInEntry+CoreDataProperties.swift
//  Calorie counter
//
//  Created by frank lasalvia on 3/5/25.
//
//

import Foundation
import CoreData


extension WeighInEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeighInEntry> {
        return NSFetchRequest<WeighInEntry>(entityName: "WeighInEntry")
    }

    @NSManaged public var time: String?
    @NSManaged public var weight: Double
    @NSManaged public var dailyRecord: DailyRecord?

}

extension WeighInEntry : Identifiable {

}
