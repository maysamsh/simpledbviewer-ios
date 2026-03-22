//
//  ListStoredCredentialsUseCase.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-05.
//

import Foundation

final class ListStoredCredentialsUseCase {
    private let secureStorageRepository: SecureStorageRepository

    init(secureStorageRepository: SecureStorageRepository) {
        self.secureStorageRepository = secureStorageRepository
    }

    func execute() throws -> [AWSCredentialNameEntity] {
        do {
            return try secureStorageRepository.listStoredCredentials()
        } catch {
            throw AppErrorMapper.map(error)
        }
    }
}
