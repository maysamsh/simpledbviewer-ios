import Combine
import Foundation
import Testing
@testable import simpledbviewer

struct AddAWSSecretsViewModelTests {
    @Test @MainActor
    func fieldUpdates_mutateState() {
        let sut = makeSUT()

        sut.handle(.updateAccessKey("AK"))
        sut.handle(.updateSecretKey("SK"))
        sut.handle(.updateProfileName("P"))
        sut.handle(.updateRegion(.usWest1))

        #expect(sut.state.accessKey == "AK")
        #expect(sut.state.secretKey == "SK")
        #expect(sut.state.profileName == "P")
        #expect(sut.state.region == .usWest1)
    }

    @Test @MainActor
    func authenticateAndSave_success_storesDismissesAndEmits() {
        let db = StubDatabaseRepository()
        let provider = DatabaseRepositoryProvider(initial: db)
        let secure = StubSecureStorageRepository()
        let unsecure = CapturingUnsecuredKeyValueStorage()
        let sut = AddAWSSecretsViewModel(
            awsNewInstanceUseCase: AWSNewInstanceUseCase(repositoryProvider: provider, repositoryFactory: { db }),
            awsRegisterUseCase: AWSRegisterUseCase(repositoryProvider: provider),
            storeCredentialsInSecureStorageUseCase: StoreCredentialsInSecureStorageUseCase(secureStorage: secure),
            setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecure))
        var emitted = false
        let c = sut.profileAdded.sink { emitted = true }

        sut.handle(.updateAccessKey("ak-test"))
        sut.handle(.updateSecretKey("sk-test"))
        sut.handle(.updateProfileName("MyProf"))
        sut.handle(.authenticateAndSave)

        #expect(db.lastRegister?.0 == "ak-test")
        #expect(secure.storedCredentials.count == 1)
        #expect(secure.storedCredentials.first?.displayName == "MyProf")
        #expect(secure.storedCredentials.first?.accessKey == "ak-test")
        if let id = secure.storedCredentials.first?.id {
            #expect(unsecure.values[.latestAddedId] == id)
        } else {
            Issue.record("Expected stored credential")
        }
        #expect(sut.state.dismiss == true)
        #expect(sut.state.error == nil)
        #expect(emitted == true)
        c.cancel()
    }

    @Test @MainActor
    func authenticateAndSave_registerFailure_setsError() {
        let db = StubDatabaseRepository()
        db.registerError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        let provider = DatabaseRepositoryProvider(initial: db)
        let secure = StubSecureStorageRepository()
        let unsecure = CapturingUnsecuredKeyValueStorage()
        let sut = AddAWSSecretsViewModel(
            awsNewInstanceUseCase: AWSNewInstanceUseCase(repositoryProvider: provider, repositoryFactory: { db }),
            awsRegisterUseCase: AWSRegisterUseCase(repositoryProvider: provider),
            storeCredentialsInSecureStorageUseCase: StoreCredentialsInSecureStorageUseCase(secureStorage: secure),
            setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecure))

        sut.handle(.updateAccessKey("a"))
        sut.handle(.updateSecretKey("b"))
        sut.handle(.authenticateAndSave)

        #expect(sut.state.dismiss == false)
        #expect(secure.storedCredentials.isEmpty)
        switch sut.state.error {
        case .some(.networkUnavailable):
            break
        default:
            Issue.record("Expected networkUnavailable")
        }
    }
}

private extension AddAWSSecretsViewModelTests {
    @MainActor
    func makeSUT() -> AddAWSSecretsViewModel {
        let db = StubDatabaseRepository()
        let provider = DatabaseRepositoryProvider(initial: db)
        return AddAWSSecretsViewModel(
            awsNewInstanceUseCase: AWSNewInstanceUseCase(repositoryProvider: provider, repositoryFactory: { db }),
            awsRegisterUseCase: AWSRegisterUseCase(repositoryProvider: provider),
            storeCredentialsInSecureStorageUseCase: StoreCredentialsInSecureStorageUseCase(secureStorage: StubSecureStorageRepository()),
            setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: CapturingUnsecuredKeyValueStorage()))
    }
}
