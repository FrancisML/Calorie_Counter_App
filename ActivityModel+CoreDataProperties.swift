//
//  ActivityModel+CoreDataProperties.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/21/25.
//
//

import Foundation
import CoreData


extension ActivityModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActivityModel> {
        return NSFetchRequest<ActivityModel>(entityName: "ActivityModel")
    }

    @NSManaged public var activityImage: Data?
    @NSManaged public var id: UUID?
    @NSManaged public var imageName: String?
    @NSManaged public var isCustom: Bool
    @NSManaged public var isFavorite: Bool
    @NSManaged public var lastUsed: Date?
    @NSManaged public var metValue: Double
    @NSManaged public var name: String?

}

extension ActivityModel : Identifiable {

}
