//
//  SetupRecentRepositoryUseCase.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-05.
//

import Foundation

final class SetupRecentRepositoryUseCase {
    private let repositoryProvider: DatabaseRepositoryProvider
    private let secureStorageRepository: SecureStorageRepository
    private let unsecuredKeyValueStorageRepository: UnsecuredKeyValueStorageRepository
    private let awsRegisterUseCase: AWSRegisterUseCase
    private let repositoryFactory: () -> DatabaseRepository

    init(repositoryProvider: DatabaseRepositoryProvider,
         secureStorageRepository: SecureStorageRepository,
         unsecuredKeyValueStorageRepository: UnsecuredKeyValueStorageRepository,
         awsRegisterUseCase: AWSRegisterUseCase,
         repositoryFactory: @escaping () -> DatabaseRepository) {
        self.repositoryProvider = repositoryProvider
        self.secureStorageRepository = secureStorageRepository
        self.unsecuredKeyValueStorageRepository = unsecuredKeyValueStorageRepository
        self.awsRegisterUseCase = awsRegisterUseCase
        self.repositoryFactory = repositoryFactory
    }

    func execute() throws {
        let credentials = try secureStorageRepository.listStoredCredentials()
        guard !credentials.isEmpty else { return }

        var recentId = unsecuredKeyValueStorageRepository.getValue(for: .latestAddedId)
        
        /// If the saved ID does not any stored credential selects the last one
        if credentials.first(where: { $0.id == recentId }) == nil {
            recentId = credentials.last?.id
        }
        
        guard let accountId = recentId else { return }
        
        let account = try secureStorageRepository.fetchCredential(for: accountId)
        guard let region = SimpleDBRegionsRepository(rawValue: account.region) else { return }

        repositoryProvider.current = repositoryFactory()
        try awsRegisterUseCase.execute(
            accessKey: account.accessKey,
            secretKey: account.secretKey,
            region: region,
            profileName: account.displayName
        )
    }
}
