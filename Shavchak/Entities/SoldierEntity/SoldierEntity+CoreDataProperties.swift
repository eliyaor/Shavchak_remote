//
//  SoldierEntity+CoreDataProperties.swift
//  Shavchak
//
//  Created by Eliya on 13/11/2022.
//
//

import Foundation
import CoreData


extension SoldierEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SoldierEntity> {
        return NSFetchRequest<SoldierEntity>(entityName: "SoldierEntity")
    }

    @NSManaged public var lastEndDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var teamName: String?

}

extension SoldierEntity : Identifiable {

}
