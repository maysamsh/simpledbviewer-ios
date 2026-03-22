import Combine
import Foundation
import Testing
@testable import simpledbviewer

struct StoredCredentialsAndAttributesViewModelTests {
    @Test @MainActor
    func storedCredentials_load_empty_showsEmptyState() {
        let secure = StubSecureStorageRepository(credentialsList: [])
        let listUC = ListStoredCredentialsUseCase(secureStorageRepository: secure)
        let unsecure = CapturingUnsecuredKeyValueStorage()
        let setUC = SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecure)
        let sut = StoredCredentialsViewModel(storedCredentialsUseCase: listUC, setUnsecuredKeyValueUseCase: setUC)

        sut.handle(StoredCredentialsViewModel.Action.load)

        if case .empty = sut.state.contentState {
        } else {
            Issue.record("Expected empty state")
        }
    }

    @Test @MainActor
    func storedCredentials_load_success_showsProfiles() {
        let names = [AWSCredentialNameEntity(id: "1", displayName: "One")]
        let secure = StubSecureStorageRepository(credentialsList: names)
        let listUC = ListStoredCredentialsUseCase(secureStorageRepository: secure)
        let unsecure = CapturingUnsecuredKeyValueStorage()
        let setUC = SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecure)
        let sut = StoredCredentialsViewModel(storedCredentialsUseCase: listUC, setUnsecuredKeyValueUseCase: setUC)

        sut.handle(StoredCredentialsViewModel.Action.load)

        if case .ready(let items) = sut.state.contentState {
            #expect(items.count == 1)
            #expect(items.first?.id == "1")
        } else {
            Issue.record("Expected ready state")
        }
    }

    @Test @MainActor
    func storedCredentials_load_failure_showsError() {
        let secure = StubSecureStorageRepository(
            credentialsList: [],
            listError: NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet))
        let listUC = ListStoredCredentialsUseCase(secureStorageRepository: secure)
        let unsecure = CapturingUnsecuredKeyValueStorage()
        let setUC = SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecure)
        let sut = StoredCredentialsViewModel(storedCredentialsUseCase: listUC, setUnsecuredKeyValueUseCase: setUC)

        sut.handle(StoredCredentialsViewModel.Action.load)

        if case .error(let err) = sut.state.contentState {
            if case .networkUnavailable = err {
            } else {
                Issue.record("Expected networkUnavailable")
            }
        } else {
            Issue.record("Expected error state")
        }
    }

    @Test @MainActor
    func storedCredentials_select_persistsLatestIdAndEmits() {
        let secure = StubSecureStorageRepository(credentialsList: [])
        let listUC = ListStoredCredentialsUseCase(secureStorageRepository: secure)
        let unsecure = CapturingUnsecuredKeyValueStorage()
        let setUC = SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecure)
        let sut = StoredCredentialsViewModel(storedCredentialsUseCase: listUC, setUnsecuredKeyValueUseCase: setUC)
        var received: AWSCredentialNameEntity?
        let cancellable = sut.profileSelected.sink { received = $0 }
        let item = AWSCredentialNameEntity(id: "acc", displayName: "Acc")

        sut.handle(StoredCredentialsViewModel.Action.select(item))

        #expect(unsecure.values[.latestAddedId] == "acc")
        #expect(received?.id == "acc")
        cancellable.cancel()
    }

    @Test @MainActor
    func attributes_reportFileName_usesShareURLComponent() {
        let url = URL(fileURLWithPath: "/tmp/export.csv")
        let tabular = TabularViewModel(buildAttributesCSVUseCase: BuildAttributesCSVUseCase())
        let sut = AttributesViewModel(tabularViewModel: tabular, shareFileURL: url)

        #expect(sut.reportFileName == "export.csv")
    }

    @Test @MainActor
    func attributes_shareSheetDescription_withoutFile_listsRecordCount() {
        let tabular = TabularViewModel(buildAttributesCSVUseCase: BuildAttributesCSVUseCase())
        tabular.handle(.setItems([
            AttributeEntity(name: "row-1", attributes: [.init(name: "c", value: "v")])
        ]))
        let sut = AttributesViewModel(tabularViewModel: tabular, shareFileURL: nil)

        #expect(sut.shareSheetDescription.contains("report.csv"))
        #expect(sut.shareSheetDescription.contains("1 records"))
    }

    @Test @MainActor
    func attributes_shareSheetDescription_withFile_includesSize() throws {
        let fileManager = FileManager.default
        let dir = fileManager.temporaryDirectory.appendingPathComponent("attr-vm-\(UUID().uuidString)")
        try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        let fileURL = dir.appendingPathComponent("data.csv")
        try "hello".write(to: fileURL, atomically: true, encoding: .utf8)
        defer { try? fileManager.removeItem(at: dir) }

        let tabular = TabularViewModel(buildAttributesCSVUseCase: BuildAttributesCSVUseCase())
        tabular.handle(.setItems([]))
        let sut = AttributesViewModel(tabularViewModel: tabular, shareFileURL: fileURL)

        let expectedSize = ByteCountFormatter.string(fromByteCount: Int64("hello".utf8.count), countStyle: .file)
        #expect(sut.shareSheetDescription.contains("data.csv"))
        #expect(sut.shareSheetDescription.contains("0 records"))
        #expect(sut.shareSheetDescription.contains(expectedSize))
    }
}
