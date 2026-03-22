//
//  AWSFetchCredentialUseCase.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-05.
//

import Foundation

final class GetCredentialFromSecureStorageUseCase {
    private let repository: SecureStorageRepository
    
    init(repository: SecureStorageRepository) {
        self.repository = repository
    }
    
    func execute(accountId: String) throws -> AWSCredentialEntity {
        do {
            return try repository.fetchCredential(for: accountId)
        } catch {
            throw AppErrorMapper.map(error)
        }
    }
}
