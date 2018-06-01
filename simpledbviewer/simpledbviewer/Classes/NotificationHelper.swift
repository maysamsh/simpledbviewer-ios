//
//  Notifications.swift
//  doudo
//
//  Created by Maysam Shahsavari on 6/8/17.
//  Copyright © 2017 Maysam Shahsavari. All rights reserved.
//

import Foundation

struct NotificationMessage{
    var title: String
    var message: String
}

enum NotificationKeys: String {
    case SetNewCredential = "SetNewCredential"
}

struct NotificationHelper {
    static func post(withKey key: NotificationKeys) {
        NotificationCenter.default.post(name: NSNotification.Name(key.rawValue), object: nil)
    }
    
}
