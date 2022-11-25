//
//  MissionNameEntity+CoreDataProperties.swift
//  Shavchak
//
//  Created by Eliya on 13/11/2022.
//
//

import Foundation
import CoreData


extension MissionNameEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MissionNameEntity> {
        return NSFetchRequest<MissionNameEntity>(entityName: "MissionNameEntity")
    }

    @NSManaged public var name: String?

}

extension MissionNameEntity : Identifiable {

}
