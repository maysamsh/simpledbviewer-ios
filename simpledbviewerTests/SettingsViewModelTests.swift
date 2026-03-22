import Foundation
import Testing
@testable import simpledbviewer

struct SettingsViewModelTests {
    @Test @MainActor
    func load_emptyCredentials_showsEmpty() {
        let secure = StubSecureStorageRepository(credentialsList: [])
        let unsecure = CapturingUnsecuredKeyValueStorage()
        let sut = makeSUT(secure: secure, unsecure: unsecure)

        sut.handle(.load)

        if case .empty = sut.state.contentState {
        } else {
            Issue.record("Expected empty")
        }
        #expect(sut.state.limitText == "100")
    }

    @Test @MainActor
    func load_ready_showsCredentials() {
        let names = [AWSCredentialNameEntity(id: "1", displayName: "A")]
        let secure = StubSecureStorageRepository(credentialsList: names)
        let unsecure = CapturingUnsecuredKeyValueStorage()
        unsecure.values[.queryDefaultLimit] = "50"
        let sut = makeSUT(secure: secure, unsecure: unsecure)

        sut.handle(.load)

        if case .ready(let list) = sut.state.contentState {
            #expect(list.count == 1)
            #expect(list.first?.id == "1")
        } else {
            Issue.record("Expected ready")
        }
        #expect(sut.state.limitText == "50")
    }

    @Test @MainActor
    func load_listFailure_showsError() {
        let secure = StubSecureStorageRepository(listError: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet))
        let sut = makeSUT(secure: secure, unsecure: CapturingUnsecuredKeyValueStorage())

        sut.handle(.load)

        if case .error(let err) = sut.state.contentState {
            switch err {
            case .networkUnavailable:
                break
            default:
                Issue.record("Expected networkUnavailable")
            }
        } else {
            Issue.record("Expected error")
        }
    }

    @Test @MainActor
    func delete_success_refreshesList() {
        let a = AWSCredentialNameEntity(id: "a", displayName: "A")
        let secure = StubSecureStorageRepository(credentialsList: [a])
        let sut = makeSUT(secure: secure, unsecure: CapturingUnsecuredKeyValueStorage())

        sut.handle(.load)
        sut.handle(.delete(a))

        #expect(secure.deletedIds == ["a"])
        if case .empty = sut.state.contentState {
        } else {
            Issue.record("Expected empty after delete")
        }
    }

    @Test @MainActor
    func delete_failure_showsError() {
        let a = AWSCredentialNameEntity(id: "a", displayName: "A")
        let secure = StubSecureStorageRepository(credentialsList: [a], deleteError: NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost))
        let sut = makeSUT(secure: secure, unsecure: CapturingUnsecuredKeyValueStorage())

        sut.handle(.load)
        sut.handle(.delete(a))

        if case .error(let err) = sut.state.contentState {
            switch err {
            case .networkUnavailable:
                break
            default:
                Issue.record("Expected networkUnavailable")
            }
        } else {
            Issue.record("Expected error")
        }
    }

    @Test @MainActor
    func submitLimit_invalid_restoresLastValid() {
        let unsecure = CapturingUnsecuredKeyValueStorage()
        unsecure.values[.queryDefaultLimit] = "100"
        let sut = makeSUT(secure: StubSecureStorageRepository(), unsecure: unsecure)

        sut.handle(.load)
        sut.handle(.updateLimitText("99999"))
        sut.handle(.submitLimit)

        #expect(sut.state.limitValidationMessage != nil)
        #expect(sut.state.limitText == "100")
    }

    @Test @MainActor
    func submitLimit_valid_persistsAndClearsMessage() {
        let unsecure = CapturingUnsecuredKeyValueStorage()
        unsecure.values[.queryDefaultLimit] = "100"
        let sut = makeSUT(secure: StubSecureStorageRepository(), unsecure: unsecure)

        sut.handle(.load)
        sut.handle(.updateLimitText("200"))
        sut.handle(.submitLimit)

        #expect(sut.state.limitValidationMessage == nil)
        #expect(sut.state.limitText == "200")
        #expect(unsecure.values[.queryDefaultLimit] == "200")
    }

    @Test @MainActor
    func updateLimitText_clearsValidationMessage() {
        let sut = makeSUT(secure: StubSecureStorageRepository(), unsecure: CapturingUnsecuredKeyValueStorage())
        sut.handle(.load)
        sut.handle(.updateLimitText("bad"))
        sut.handle(.submitLimit)
        #expect(sut.state.limitValidationMessage != nil)

        sut.handle(.updateLimitText("10"))

        #expect(sut.state.limitValidationMessage == nil)
    }
}

private extension SettingsViewModelTests {
    @MainActor
    func makeSUT(secure: StubSecureStorageRepository, unsecure: CapturingUnsecuredKeyValueStorage) -> SettingsViewModel {
        SettingsViewModel(
            listCredentialsUseCase: ListStoredCredentialsUseCase(secureStorageRepository: secure),
            deleteCredentialUseCase: DeleteCredentialUseCase(secureStorageRepository: secure),
            getUnsecuredKeyValueUseCase: GetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecure),
            setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecure))
    }
}
