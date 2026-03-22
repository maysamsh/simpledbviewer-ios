//
//  DependencyContainer.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-03.
//

import Foundation

final class DependencyContainer {
    private let databaseRepositoryProvider = DatabaseRepositoryProvider(initial: NoDatabaseRepository())
    private let secureStorageRepository: SecureStorageRepository = KeychainRepository()
    private let unsecuredKeyValueStorageRepository: UnsecuredKeyValueStorageRepository = UserDefaultsRepository()
    private let legacyStorageRepository: LegacyStorageRepository = CoreDataLegacyRepository()

    @MainActor
    func makeCredentialsCoordinator() -> CredentialsCoordinator {
        CredentialsCoordinator(
            awsNewInstanceUseCase: AWSNewInstanceUseCase(repositoryProvider: databaseRepositoryProvider,
                                                        repositoryFactory: { SimpleDBRepository() }),
            awsRegisterUseCase: AWSRegisterUseCase(repositoryProvider: databaseRepositoryProvider),
            getCredentialsFromSecureStorageUseCase: GetCredentialFromSecureStorageUseCase(repository: secureStorageRepository),
            listStoredCredentialsUseCase: ListStoredCredentialsUseCase(secureStorageRepository: secureStorageRepository),
            storeCredentialsInSecureStorageUseCase: StoreCredentialsInSecureStorageUseCase(secureStorage: secureStorageRepository),
            setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecuredKeyValueStorageRepository))
    }
    
    @MainActor
    func makeHomeViewModel(coordinator: CredentialsCoordinator) -> HomeViewModel {
        HomeViewModel(
            getDomainsListUseCase: AWSFetchDomainsUseCase(repositoryProvider: databaseRepositoryProvider),
            awsGetAttributesUseCase: AWSFetchAttributesUseCase(repositoryProvider: databaseRepositoryProvider),
            buildAttributesCSVUseCase: BuildAttributesCSVUseCase(),
            exportCSVToTemporaryFileUseCase: ExportCSVToTemporaryFileUseCase(repository: TemporaryCSVFileRepository()),
            getActiveProfileNameUseCase: GetActiveProfileNameUseCase(repositoryProvider: databaseRepositoryProvider),
            coordinator: coordinator)
    }

    @MainActor
    func makeSettingsViewModel() -> SettingsViewModel {
        let getUnsecuredKeyValueUseCase = GetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecuredKeyValueStorageRepository)
        let setUnsecuredKeyValueUseCase = SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecuredKeyValueStorageRepository)
        return SettingsViewModel(
            listCredentialsUseCase: ListStoredCredentialsUseCase(secureStorageRepository: secureStorageRepository),
            deleteCredentialUseCase: DeleteCredentialUseCase(secureStorageRepository: secureStorageRepository),
            getUnsecuredKeyValueUseCase: getUnsecuredKeyValueUseCase,
            setUnsecuredKeyValueUseCase: setUnsecuredKeyValueUseCase
        )
    }

    @MainActor
    func performStartup() {
        let awsRegisterUseCase = AWSRegisterUseCase(repositoryProvider: databaseRepositoryProvider)
        let setupUseCase = SetupRecentRepositoryUseCase(
            repositoryProvider: databaseRepositoryProvider,
            secureStorageRepository: secureStorageRepository,
            unsecuredKeyValueStorageRepository: unsecuredKeyValueStorageRepository,
            awsRegisterUseCase: awsRegisterUseCase,
            repositoryFactory: { SimpleDBRepository() })
        try? setupUseCase.execute()

        let getKeyValue = GetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecuredKeyValueStorageRepository)
        guard getKeyValue.execute(key: .migrationToV2) == nil else { return }
        let migration = MigrateLegacyCredentialsUseCase(
            legacyStorageRepository: legacyStorageRepository,
            secureStorageRepository: secureStorageRepository,
            unsecuredKeyValueStorageRepository: unsecuredKeyValueStorageRepository)
        try? migration.execute()
    }
}
