//
//  AWSAccessInfo+CoreDataClass.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 5/30/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//
//

import Foundation
import CoreData

@objc(AWSAccessInfo)
public class AWSAccessInfo: NSManagedObject {
    class func get(context: NSManagedObjectContext) -> AWSAccessInfo?{
        let request: NSFetchRequest<AWSAccessInfo> = AWSAccessInfo.fetchRequest()
        let id  = NSPredicate(format: "id = %@", Constants.kDefault)
        request.predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [id])
        do {
            let matches = try context.fetch(request)
            return matches.first
        }catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    class func add(info: Credential , context: NSManagedObjectContext) {
        let credentials = AWSAccessInfo(context: context)
        credentials.key = info.key
        credentials.secret = info.secret
        credentials.region = info.region
        credentials.id = Constants.kDefault
        try? context.save()
    }
    
    class func update(info: Credential, context: NSManagedObjectContext) {
        let request: NSFetchRequest<AWSAccessInfo> = AWSAccessInfo.fetchRequest()
        let id  = NSPredicate(format: "id = %@", Constants.kDefault)
        request.predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [id])
        do {
            let matches = try context.fetch(request)
            if let managedObject =  matches.first {
                managedObject.key = info.key
                managedObject.secret = info.secret
                managedObject.region = info.region
                do {
                    try context.save()
                }catch let error {
                    print(error.localizedDescription)
                }
            }
        }catch let error {
            print(error.localizedDescription)
        }
    }
}
