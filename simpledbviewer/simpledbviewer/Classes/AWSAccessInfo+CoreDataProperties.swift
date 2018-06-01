//
//  AWSAccessInfo+CoreDataProperties.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 5/30/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//
//

import Foundation
import CoreData


extension AWSAccessInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AWSAccessInfo> {
        return NSFetchRequest<AWSAccessInfo>(entityName: "AWSAccessInfo")
    }

    @NSManaged public var id: String?
    @NSManaged public var key: String?
    @NSManaged public var secret: String?
    @NSManaged public var region: String?

}
