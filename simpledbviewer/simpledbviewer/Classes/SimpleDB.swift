//
//  SimpleDBHelpper.swift
//  genericDaroo
//
//  Created by Maysam Shahsavari on 2/8/17.
//  Copyright © 2017 Maysam Shahsavari. All rights reserved.
//

import Foundation
import AWSSimpleDB

struct awsKeyValuePair {
    let name: String
    let value: String
}
struct awsKeyValuePairWithItem {
    let itemName: String
    let name: String
    let value: String
}

struct Credential {
    let secret: String
    let key: String
    let region: String
}

typealias awsItemName = String

class SimpleDB {

    private static var awsAccessKey: String = ""
    private static var awsSecretKey: String = ""
    private static var awsRegion: AWSRegionType = .Unknown
    
    private lazy var sdb = AWSSimpleDB.init(forKey: Constants.kDefault)
    
    private static var sharedInstance:SimpleDB = {
        return SimpleDB()
    }()
    
    class func shared(info: Credential?) -> SimpleDB{
        if let _info = info {
            self.awsSecretKey = _info.secret
            self.awsRegion = AWSRegionType.regionTypeForString(regionString: _info.region)
            self.awsAccessKey = _info.key
        }
        return sharedInstance
    }
    
    private init () {
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey:SimpleDB.awsAccessKey, secretKey: SimpleDB.awsSecretKey)
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: SimpleDB.awsRegion, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration
            = defaultServiceConfiguration
        AWSSimpleDB.register(with: defaultServiceConfiguration!, forKey: Constants.kDefault)
    }
    
    func resetCredentias(){
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey:SimpleDB.awsAccessKey, secretKey: SimpleDB.awsSecretKey)
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: SimpleDB.awsRegion, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration
            = defaultServiceConfiguration
        AWSSimpleDB.remove(forKey: Constants.kDefault)
        sdb = AWSSimpleDB.init(forKey: Constants.kDefault)
        AWSSimpleDB.register(with: defaultServiceConfiguration!, forKey: Constants.kDefault)
    }
    
    func putAttributes(items: [awsKeyValuePair], domain: String, completion:@escaping (Error?)-> Void){
        guard items.count > 0 else {
            completion(Failure.emptyAttributes)
            
            return
        }
        
        let putRequest = AWSSimpleDBPutAttributesRequest()
        putRequest?.domainName = domain
        var attributes = [AWSSimpleDBReplaceableAttribute]()
        for row in items {
            let attribute = AWSSimpleDBReplaceableAttribute()
            attribute?.name = row.name
            attribute?.value = row.value 
            if attribute != nil {
                attributes.append(attribute!)
            }
        }
        
        putRequest?.attributes = attributes
        putRequest?.itemName = UUID().uuidString
        if let _putRequest = putRequest {
            sdb.putAttributes(_putRequest) { (error) in
                completion(error)
            }
        }else{
            completion(Failure.invalidRequest)
        }
    }
    
    
    func batchReplaceAttributes(itemAttributes: [awsKeyValuePairWithItem], domain: String,
                                completion: ((Error?) -> Void)?)
    {
        guard itemAttributes.count > 0 else {
            completion?(Failure.emptyAttributes)
            return
        }
        let batchPutRequest = AWSSimpleDBBatchPutAttributesRequest()
        batchPutRequest?.domainName = domain
        var items = [AWSSimpleDBReplaceableItem]()
        for _item in itemAttributes {
            let attribute = AWSSimpleDBReplaceableAttribute()
            let replacableItem = AWSSimpleDBReplaceableItem()
            attribute?.name = _item.name
            attribute?.value = _item.value
            attribute?.replace = true
            replacableItem?.name = _item.itemName
            replacableItem?.attributes = [attribute!]
            items.append(replacableItem!)
        }
        batchPutRequest?.items = items
        if let _batchPutRequest = batchPutRequest {
            sdb.batchPutAttributes(_batchPutRequest) { (error) in
                completion?(error)
            }
        }else{
            completion?(Failure.invalidRequest)
        }
        
    }
    
    func putAttributes(items: [awsKeyValuePair], domain: String, completion:@escaping (String, Error?)-> Void){
        guard items.count > 0 else {
            completion("", Failure.emptyAttributes)
            
            return
        }
        
        let putRequest = AWSSimpleDBPutAttributesRequest()
        putRequest?.domainName = domain
        var attributes = [AWSSimpleDBReplaceableAttribute]()
        for row in items {
            let attribute = AWSSimpleDBReplaceableAttribute()
            attribute?.name = row.name
            attribute?.value = row.value
            if attribute != nil {
                attributes.append(attribute!)
            }
        }
        
        putRequest?.attributes = attributes
        let itemName = UUID().uuidString
        putRequest?.itemName = itemName
        if let _putRequest = putRequest {
            sdb.putAttributes(_putRequest) { (error) in
                completion(itemName, error)
            }
        }else{
            completion("", Failure.invalidRequest)
        }
        
    }
    
    func replaceAttributes(itemName:awsItemName, itemAttributes: [awsKeyValuePair], domain: String, completion:@escaping (Error?)-> Void){
        guard itemAttributes.count > 0 else {
            completion(Failure.emptyAttributes)
            return
        }
        
        let putRequest = AWSSimpleDBPutAttributesRequest()
        putRequest?.domainName = domain
        putRequest?.itemName = itemName
        var attributes = [AWSSimpleDBReplaceableAttribute]()
        for row in itemAttributes {
            let attribute = AWSSimpleDBReplaceableAttribute()
            attribute?.name = row.name
            attribute?.replace = true
            attribute?.value = row.value
            if attribute != nil {
                attributes.append(attribute!)
            }
        }
        putRequest?.attributes = attributes
        if let _putRequest = putRequest {
            sdb.putAttributes(_putRequest) { (error) in
                completion(error)
            }
        }else{
            completion(Failure.invalidRequest)
        }
        
    }
    
    func getAttributes(selectExpression:String, completion:@escaping (AWSSimpleDBSelectResult?, Error?)-> Void){
        let selectRequest = AWSSimpleDBSelectRequest()
        selectRequest?.selectExpression = selectExpression
        if let _selectRequest = selectRequest {
            sdb.select(_selectRequest) { (selectResult, error) in
                completion(selectResult, error)
            }
        }else{
            completion(nil, Failure.invalidRequest)
        }
        
    }
    
    func listDomains(completion:@escaping (AWSSimpleDBListDomainsResult?, Error?)-> Void){
        let listDomainsRequest = AWSSimpleDBListDomainsRequest()
        listDomainsRequest?.maxNumberOfDomains = 100
        if let _listDomainsRequest = listDomainsRequest {
            sdb.listDomains(_listDomainsRequest) { (listDomainsResult, error) in
                completion(listDomainsResult, error)
            }
        }else{
            completion(nil, Failure.invalidRequest)
        }
        
    }
}
