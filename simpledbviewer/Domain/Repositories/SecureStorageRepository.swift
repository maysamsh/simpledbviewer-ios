//
//  SecureStorageRepository.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-05.
//
protocol SecureStorageRepository {
    func listStoredCredentials() throws -> [AWSCredentialNameEntity]
    func fetchCredential(for id: String) throws -> AWSCredentialEntity
    func storeCredential(_ data: AWSCredentialEntity) throws
    func updateCredential(_ data: AWSCredentialEntity) throws
    func deleteCredential(for id: String) throws
    func deleteAllCredentials() throws
}
