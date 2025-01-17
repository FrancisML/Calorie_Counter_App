//
//  ProgressPicture+CoreDataProperties.swift
//  Calorie counter
//
//  Created by frank lasalvia on 1/15/25.
//
//

import Foundation
import CoreData


extension ProgressPicture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProgressPicture> {
        return NSFetchRequest<ProgressPicture>(entityName: "ProgressPicture")
    }

    @NSManaged public var uuid: UUID?
    @NSManaged public var imageData: Data?
    @NSManaged public var date: Date?
    @NSManaged public var weight: Int32
    @NSManaged public var relationship: UserProfile?

}

extension ProgressPicture : Identifiable {

}
