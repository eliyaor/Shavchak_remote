//
//  TeamEntity+CoreDataProperties.swift
//  Shavchak
//
//  Created by Eliya on 13/11/2022.
//
//

import Foundation
import CoreData


extension TeamEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamEntity> {
        return NSFetchRequest<TeamEntity>(entityName: "TeamEntity")
    }

    @NSManaged public var name: String?

}

extension TeamEntity : Identifiable {

}
