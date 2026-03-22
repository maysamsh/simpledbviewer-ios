//
//  DeleteCredentialUseCase.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-05.
//

import Foundation

final class DeleteCredentialUseCase {
    private let secureStorageRepository: SecureStorageRepository

    init(secureStorageRepository: SecureStorageRepository) {
        self.secureStorageRepository = secureStorageRepository
    }

    func execute(id: String) throws {
        do {
            try secureStorageRepository.deleteCredential(for: id)
        } catch {
            throw AppErrorMapper.map(error)
        }
    }
}
