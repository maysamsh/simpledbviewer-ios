import Foundation
import Testing
@testable import simpledbviewer

struct SecureStorageAndMigrationUseCaseTests {
    @Test
    func migrateLegacy_noLegacy_setsMigrationDone() throws {
        let legacy = StubLegacyStorageRepository(credential: nil)
        let secure = StubSecureStorageRepository()
        let unsecure = CapturingUnsecuredKeyValueStorage()
        let sut = MigrateLegacyCredentialsUseCase(
            legacyStorageRepository: legacy,
            secureStorageRepository: secure,
            unsecuredKeyValueStorageRepository: unsecure)

        try sut.execute()

        #expect(secure.storedCredentials.isEmpty)
        #expect(legacy.deleteLegacyDataCalled == false)
        #expect(unsecure.values[.migrationToV2] == "done")
    }

    @Test
    func migrateLegacy_success_storesDeletesAndMarksDone() throws {
        let cred = AWSCredentialEntity(id: "1", displayName: "P", region: "us-east-1", accessKey: "a", secretKey: "s")
        let legacy = StubLegacyStorageRepository(credential: cred)
        let secure = StubSecureStorageRepository()
        let unsecure = CapturingUnsecuredKeyValueStorage()
        let sut = MigrateLegacyCredentialsUseCase(
            legacyStorageRepository: legacy,
            secureStorageRepository: secure,
            unsecuredKeyValueStorageRepository: unsecure)

        try sut.execute()

        #expect(secure.storedCredentials.count == 1)
        #expect(secure.storedCredentials.first?.id == cred.id)
        #expect(legacy.deleteLegacyDataCalled == true)
        #expect(unsecure.values[.migrationToV2] == "done")
    }

    @Test
    func migrateLegacy_storeFails_setsFailedAndRethrows() {
        let cred = AWSCredentialEntity(id: "1", displayName: "P", region: "us-east-1", accessKey: "a", secretKey: "s")
        let legacy = StubLegacyStorageRepository(credential: cred)
        let secure = StubSecureStorageRepository(storeError: NSError(domain: "t", code: 1))
        let unsecure = CapturingUnsecuredKeyValueStorage()
        let sut = MigrateLegacyCredentialsUseCase(
            legacyStorageRepository: legacy,
            secureStorageRepository: secure,
            unsecuredKeyValueStorageRepository: unsecure)

        var didThrow = false
        do {
            try sut.execute()
        } catch {
            didThrow = true
        }
        #expect(didThrow)

        #expect(unsecure.values[.migrationToV2] == "failed")
        #expect(legacy.deleteLegacyDataCalled == false)
    }

    @Test
    func listStoredCredentials_success_returnsFromRepository() throws {
        let expected = [AWSCredentialNameEntity(id: "x", displayName: "X")]
        let secure = StubSecureStorageRepository(credentialsList: expected)
        let sut = ListStoredCredentialsUseCase(secureStorageRepository: secure)

        let result = try sut.execute()

        #expect(result.count == 1)
        #expect(result.first?.id == "x")
    }

    @Test
    func listStoredCredentials_failure_mapsError() {
        let secure = StubSecureStorageRepository(listError: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet))
        let sut = ListStoredCredentialsUseCase(secureStorageRepository: secure)

        do {
            _ = try sut.execute()
            Issue.record("Expected throw")
        } catch let error as AppError {
            if case .networkUnavailable = error {
            } else {
                Issue.record("Expected networkUnavailable")
            }
        } catch {
            Issue.record("Expected AppError, got \(String(describing: type(of: error)))")
        }
    }

    @Test
    func getCredential_success() throws {
        let entity = AWSCredentialEntity(id: "1", displayName: "P", region: "us-east-1", accessKey: "a", secretKey: "s")
        let secure = StubSecureStorageRepository(fetchResult: entity)
        let sut = GetCredentialFromSecureStorageUseCase(repository: secure)

        let got = try sut.execute(accountId: "1")

        #expect(got.id == entity.id)
        #expect(secure.lastFetchId == "1")
    }

    @Test
    func getCredential_failure_mapsError() {
        let secure = StubSecureStorageRepository(fetchError: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet))
        let sut = GetCredentialFromSecureStorageUseCase(repository: secure)

        do {
            _ = try sut.execute(accountId: "1")
            Issue.record("Expected throw")
        } catch let error as AppError {
            if case .networkUnavailable = error {
            } else {
                Issue.record("Expected networkUnavailable")
            }
        } catch {
            Issue.record("Expected AppError")
        }
    }

    @Test
    func deleteCredential_delegatesToRepository() throws {
        let secure = StubSecureStorageRepository()
        let sut = DeleteCredentialUseCase(secureStorageRepository: secure)

        try sut.execute(id: "abc")

        #expect(secure.deletedIds == ["abc"])
    }

    @Test
    func deleteCredential_failure_mapsError() {
        let secure = StubSecureStorageRepository(deleteError: NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost))
        let sut = DeleteCredentialUseCase(secureStorageRepository: secure)

        do {
            try sut.execute(id: "abc")
            Issue.record("Expected throw")
        } catch let error as AppError {
            if case .networkUnavailable = error {
            } else {
                Issue.record("Expected networkUnavailable")
            }
        } catch {
            Issue.record("Expected AppError")
        }
    }

    @Test
    func storeCredentials_delegatesToRepository() throws {
        let secure = StubSecureStorageRepository()
        let sut = StoreCredentialsInSecureStorageUseCase(secureStorage: secure)
        let entity = AWSCredentialEntity(id: "1", displayName: "P", region: "us-east-1", accessKey: "a", secretKey: "s")

        try sut.execute(entity)

        #expect(secure.storedCredentials.count == 1)
        #expect(secure.storedCredentials.first?.accessKey == "a")
    }

    @Test
    func getUnsecuredKeyValue_readsFromRepository() {
        let unsecure = CapturingUnsecuredKeyValueStorage()
        unsecure.values[.queryDefaultLimit] = "25"
        let sut = GetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecure)

        #expect(sut.execute(key: .queryDefaultLimit) == "25")
    }

    @Test
    func setUnsecuredKeyValue_writesToRepository() {
        let unsecure = CapturingUnsecuredKeyValueStorage()
        let sut = SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecure)

        sut.execute(key: .latestAddedId, value: "id-99")

        #expect(unsecure.values[.latestAddedId] == "id-99")
    }
}
