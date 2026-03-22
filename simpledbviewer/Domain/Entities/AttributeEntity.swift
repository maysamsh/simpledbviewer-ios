//
//  AttributeEntity.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-03.
//
import Foundation

struct AttributeEntity: Identifiable {
    let name: String
    let attributes: [Attribute]
    var id: String { name }

    struct Attribute {
        let name: String
        let value: String
    }
}
