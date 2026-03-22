//
//  AWSCredentialEntity.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-05.
//

struct AWSCredentialEntity: Identifiable {
    let id: String
    let displayName: String
    let region: String
    let accessKey: String
    let secretKey: String
}

struct AWSCredentialNameEntity: Identifiable {
    let id: String
    let displayName: String
}
