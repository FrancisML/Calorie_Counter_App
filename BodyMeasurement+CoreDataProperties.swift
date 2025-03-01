//
//  BodyMeasurement+CoreDataProperties.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/26/25.
//
//

import Foundation
import CoreData


extension BodyMeasurement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BodyMeasurement> {
        return NSFetchRequest<BodyMeasurement>(entityName: "BodyMeasurement")
    }

    @NSManaged public var chest: Double
    @NSManaged public var waist: Double
    @NSManaged public var hips: Double
    @NSManaged public var leftArm: Double
    @NSManaged public var rightArm: Double
    @NSManaged public var leftThigh: Double
    @NSManaged public var rightThigh: Double
    @NSManaged public var date: Date?
    @NSManaged public var userProfile: UserProfile?

}

extension BodyMeasurement : Identifiable {

}
