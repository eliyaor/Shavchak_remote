//
//  MissionEntity+CoreDataProperties.swift
//  Shavchak
//
//  Created by Eliya on 13/11/2022.
//
//

import Foundation
import CoreData


extension MissionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MissionEntity> {
        return NSFetchRequest<MissionEntity>(entityName: "MissionEntity")
    }

    @NSManaged public var end: Date?
    @NSManaged public var start: Date?
    @NSManaged public var name: String?
    @NSManaged public var soldiers: String?

}

extension MissionEntity : Identifiable {

}
