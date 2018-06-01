//
//  String+Ext.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 5/30/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//

import Foundation
extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
