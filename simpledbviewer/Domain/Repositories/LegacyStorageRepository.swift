//
//  LegacyStorageRepository.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-10.
//

protocol LegacyStorageRepository {
    func fetchLegacyCredential() throws -> AWSCredentialEntity?
    func deleteLegacyData() throws
}
