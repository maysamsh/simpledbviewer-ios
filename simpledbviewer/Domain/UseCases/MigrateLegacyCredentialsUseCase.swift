//
//  MigrateLegacyCredentialsUseCase.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-10.
//

final class MigrateLegacyCredentialsUseCase {
    private let legacyStorageRepository: LegacyStorageRepository
    private let secureStorageRepository: SecureStorageRepository
    private let unsecuredKeyValueStorageRepository: UnsecuredKeyValueStorageRepository

    init(legacyStorageRepository: LegacyStorageRepository,
         secureStorageRepository: SecureStorageRepository,
         unsecuredKeyValueStorageRepository: UnsecuredKeyValueStorageRepository) {
        self.legacyStorageRepository = legacyStorageRepository
        self.secureStorageRepository = secureStorageRepository
        self.unsecuredKeyValueStorageRepository = unsecuredKeyValueStorageRepository
    }

    func execute() throws {
        guard let legacyCredentials = try legacyStorageRepository.fetchLegacyCredential() else {
            unsecuredKeyValueStorageRepository.setValue(key: .migrationToV2, value: "done")
            return
        }
        do {
            try secureStorageRepository.storeCredential(legacyCredentials)
            try legacyStorageRepository.deleteLegacyData()
            unsecuredKeyValueStorageRepository.setValue(key: .migrationToV2, value: "done")
        } catch {
            unsecuredKeyValueStorageRepository.setValue(key: .migrationToV2, value: "failed")
            throw error
        }
    }
}
