import Foundation
import Testing
@testable import simpledbviewer

struct CSVExportFlowTests {
    @Test
    func temporaryCSVFileWriter_overwritesReportFile() throws {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory.appendingPathComponent("simpledbviewer-tests-\(UUID().uuidString)", isDirectory: true)
        try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDirectory) }
        let sut = TemporaryCSVFileRepository(fileManager: fileManager, directoryURL: tempDirectory)

        let firstURL = try sut.writeToTemporaryFile(csvContent: "first", fileName: "report.csv")
        let secondURL = try sut.writeToTemporaryFile(csvContent: "second", fileName: "report.csv")
        let finalContent = try String(contentsOf: secondURL, encoding: .utf8)

        #expect(firstURL == secondURL)
        #expect(secondURL.lastPathComponent == "report.csv")
        #expect(finalContent == "second")
    }

    @Test @MainActor
    func homeViewModel_exportCSVForSharing_setsShareFileURLOnSuccess() {
        let expectedURL = URL(fileURLWithPath: "/tmp/report.csv")
        let exportRepository = MockCSVFileRepository(result: .success(expectedURL))
        let exportUseCase = ExportCSVToTemporaryFileUseCase(repository: exportRepository)
        let sut = makeHomeViewModel(buildAttributesCSVUseCase: BuildAttributesCSVUseCase(), exportCSVToTemporaryFileUseCase: exportUseCase)
        sut.tabularViewModel.handle(.setItems([
            AttributeEntity(name: "row-1", attributes: [.init(name: "title1", value: "value-1")])
        ]))

        sut.handle(.exportCSVForSharing)

        #expect(sut.state.shareFileURL == expectedURL)
        #expect(sut.state.error == nil)
        #expect(exportRepository.receivedCSVContent == """
        Item Name,title1
        row-1,value-1
        """)
        #expect(exportRepository.receivedFileName == "report.csv")
    }

    @Test @MainActor
    func homeViewModel_exportCSVForSharing_mapsFailureToAppError() {
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        let exportUseCase = ExportCSVToTemporaryFileUseCase(repository: MockCSVFileRepository(result: .failure(networkError)))
        let sut = makeHomeViewModel(buildAttributesCSVUseCase: BuildAttributesCSVUseCase(), exportCSVToTemporaryFileUseCase: exportUseCase)

        sut.handle(.exportCSVForSharing)

        #expect(sut.state.shareFileURL == nil)
        #expect(isNetworkUnavailable(sut.state.error))
    }

    @MainActor
    private func makeHomeViewModel(buildAttributesCSVUseCase: BuildAttributesCSVUseCase,
                                   exportCSVToTemporaryFileUseCase: ExportCSVToTemporaryFileUseCase) -> HomeViewModel {
        let repositoryProvider = DatabaseRepositoryProvider(initial: StubDatabaseRepository())
        let secureStorage = StubSecureStorageRepository()
        let unsecureStorage = CapturingUnsecuredKeyValueStorage()
        let coordinator = CredentialsCoordinator(
            awsNewInstanceUseCase: AWSNewInstanceUseCase(repositoryProvider: repositoryProvider, repositoryFactory: { StubDatabaseRepository() }),
            awsRegisterUseCase: AWSRegisterUseCase(repositoryProvider: repositoryProvider),
            getCredentialsFromSecureStorageUseCase: GetCredentialFromSecureStorageUseCase(repository: secureStorage),
            listStoredCredentialsUseCase: ListStoredCredentialsUseCase(secureStorageRepository: secureStorage),
            storeCredentialsInSecureStorageUseCase: StoreCredentialsInSecureStorageUseCase(secureStorage: secureStorage),
            setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecureStorage))
        return HomeViewModel(getDomainsListUseCase: AWSFetchDomainsUseCase(repositoryProvider: repositoryProvider),
                             awsGetAttributesUseCase: AWSFetchAttributesUseCase(repositoryProvider: repositoryProvider),
                             buildAttributesCSVUseCase: buildAttributesCSVUseCase,
                             exportCSVToTemporaryFileUseCase: exportCSVToTemporaryFileUseCase,
                             getActiveProfileNameUseCase: GetActiveProfileNameUseCase(repositoryProvider: repositoryProvider),
                             coordinator: coordinator)
    }

    private func isNetworkUnavailable(_ error: AppError?) -> Bool {
        if case .networkUnavailable? = error { return true }
        return false
    }
}
