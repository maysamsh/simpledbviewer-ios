//
//  NSError+Ext.swift
//  richee
//
//  Created by Maysam Shahsavari on 11/20/17.
//  Copyright © 2017 Maysam Shahsavari. All rights reserved.
//

import Foundation

enum Failure: Error {
    case emptyAttributes
    case simpleDBError
    case emptyList
    case networkError
    case invalidItemType
    case invalidAttributes
    case invalidRequest
    case invalidResults
    case unknownAWSError
    
    var localizedDescription: String {
        switch self {
        case .networkError:
            return "Network error."
        case .emptyList:
            return "AWS: Empty list."
        case .emptyAttributes:
            return "AWS: Empty Attribute."
        case .simpleDBError:
            return "AWS: SimpleDB error."
        case .invalidItemType:
            return "AWS: Invalid item type."
        case .invalidAttributes:
            return "AWS: Invalid attributes."
        case .invalidRequest:
            return "AWS: Invalid request."
        case .invalidResults:
            return "AWS: Invalid result."
        case .unknownAWSError:
            return "AWS: Unknonw error."
            
        }
    }
}

func ==(lhs:Failure, rhs:Failure) -> Bool {
    if lhs.hashValue == rhs.hashValue {
        return true
    }else{
        return false
    }
}
