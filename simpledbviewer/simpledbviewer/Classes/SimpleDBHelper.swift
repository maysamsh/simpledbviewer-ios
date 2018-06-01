//
//  SimpleDBHelper.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 5/21/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//

import Foundation
import AWSSimpleDB

struct Constants {
    static let kDefault = "default"
}
struct SimpleDBHelper {

    private static var awsCredential: Credential?
    
    private static var simpleDB = SimpleDB.shared(info: awsCredential)
    
    static func setCredentials(with credential: Credential, completion: @escaping(Bool, Error?) -> Void){
        let _simpleDB = SimpleDB.shared(info: credential)
        _simpleDB.resetCredentias()
        _simpleDB.listDomains { (results, error) in
            if let _ = error {
                completion(false, error)
            }else if let _ = results {
                completion(true, nil)
            }else{
                completion(false, Failure.unknownAWSError)
            }
        }
    }
    
    static func listDomains(completion:@escaping ([String],Error?)->Void) {
        simpleDB.listDomains { (results, error) in
            if let _error = error {
                completion([], _error)
            }else{
                var domains = [String]()
                if let _results = results?.domainNames {
                    for item in _results {
                        domains.append(item)
                    }
                    completion(domains, nil)
                }else{
                    completion(domains, nil)
                }
            }
        }
    }
    
    static func viewDomainContents(domain:String, completion:@escaping ([AWSSimpleDBItem]?, Error?)-> Void){
        let query = "SELECT * FROM \(domain)"
        simpleDB.getAttributes(selectExpression: query) { (result, error) in
            if let _error = error {
                completion(nil, _error)
            }else{
                completion(result?.items, nil)
            }
        }
    }
}
