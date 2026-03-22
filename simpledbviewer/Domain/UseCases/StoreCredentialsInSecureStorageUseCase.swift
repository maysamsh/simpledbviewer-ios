//
//  StoreCredentialsInSecureStorageUseCase.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-08.
//

final class StoreCredentialsInSecureStorageUseCase {
    private let secureStorage: SecureStorageRepository
    
    init(secureStorage: SecureStorageRepository) {
        self.secureStorage = secureStorage
    }
    
    func execute(_ account: AWSCredentialEntity) throws {
        try secureStorage.storeCredential(account)
    }
}
