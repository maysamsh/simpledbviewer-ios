//
//  AWSRegionTypeHelpers.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 5/29/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//

import Foundation
import AWSCore

extension AWSRegionType {
    static func allRegions() -> [String] {
        return  [
        "us-east-1"
        , "us-west-1"
        , "us-west-2"
        , "eu-west-1"
        , "eu-west-2"
        , "eu-west-3"
        , "eu-central-1"
        , "ap-northeast-1"
        , "ap-northeast-2"
        , "ap-southeast-1"
        , "ap-southeast-2"
        , "sa-east-1"
        , "cn-north-1"
        , "cn-northwest-1"
        , "ca-central-1"
        , "us-gov-west-1"
        ]
    }
    
    static func regionTypeForString(regionString: String) -> AWSRegionType {
        switch regionString {
        case "us-east-1": return .USEast1
        case "us-west-1": return .USWest1
        case "us-west-2": return .USWest2
        case "eu-west-1": return .EUWest1
        case "eu-west-2": return .EUWest2
        case "eu-west-3": return .EUWest3
        case "eu-central-1": return .EUCentral1
        case "ap-northeast-1": return .APNortheast1
        case "ap-northeast-2": return .APNortheast2
        case "ap-southeast-1": return .APSoutheast1
        case "ap-southeast-2": return .APSoutheast2
        case "sa-east-1": return .SAEast1
        case "cn-north-1": return .CNNorth1
        case "cn-northwest-1": return .CNNorthWest1
        case "ca-central-1": return .CACentral1
        case "us-gov-west-1": return .USGovWest1
        default: return .Unknown
        }
    }
    
    var stringValue: String {
        switch self {
        case .USEast1: return "us-east-1"
        case .USWest1: return "us-west-1"
        case .USWest2: return "us-west-2"
        case .EUWest1: return "eu-west-1"
        case .EUWest2: return "eu-west-2"
        case .EUWest3: return "eu-west-3"
        case .EUCentral1: return "eu-central-1"
        case .APNortheast1: return "ap-northeast-1"
        case .APNortheast2: return "ap-northeast-2"
        case .APSoutheast1: return "ap-southeast-1"
        case .APSoutheast2: return "ap-southeast-2"
        case .SAEast1: return "sa-east-1"
        case .CNNorth1: return "cn-north-1"
        case .CNNorthWest1: return "cn-northwest-1"
        case .CACentral1: return "ca-central-1"
        case .USGovWest1: return "us-gov-west-1"
        default: return "Unknown"
        }
    }
}
