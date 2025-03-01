//
//  ProgressPicture+CoreDataProperties.swift
//  Calorie counter
//
//  Created by frank lasalvia on 2/26/25.
//
//

import Foundation
import CoreData


extension ProgressPicture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProgressPicture> {
        return NSFetchRequest<ProgressPicture>(entityName: "ProgressPicture")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var date: Date?
    @NSManaged public var weight: Double
    @NSManaged public var userProfile: UserProfile?

}

extension ProgressPicture : Identifiable {

}
