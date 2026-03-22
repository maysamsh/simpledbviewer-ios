import Foundation
import Testing
@testable import simpledbviewer

struct HomeViewModelTests {
    @Test @MainActor
    func getDomains_success_setsDomainsAndProfile() async {
        let db = StubDatabaseRepository()
        db.domains = ["a", "b"]
        db.profileName = "Prof"
        let sut = Self.makeSUT(database: db)

        sut.handle(.getDomains)
        await MainActorTestWait.waitUntil { !sut.state.isLoading }

        #expect(sut.state.domains == ["a", "b"])
        #expect(sut.state.profileName == "Prof")
        #expect(sut.state.isNotConfigured == false)
        #expect(sut.state.error == nil)
    }

    @Test @MainActor
    func getDomains_noCredentials_setsNotConfigured() async {
        let db = StubDatabaseRepository()
        db.listDomainsError = AppError.noCredentials
        let sut = Self.makeSUT(database: db)

        sut.handle(.getDomains)
        await MainActorTestWait.waitUntil { !sut.state.isLoading }

        #expect(sut.state.domains.isEmpty)
        #expect(sut.state.isNotConfigured == true)
        #expect(sut.state.error == nil)
    }

    @Test @MainActor
    func getDomains_otherError_setsError() async {
        let db = StubDatabaseRepository()
        db.listDomainsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        let sut = Self.makeSUT(database: db)

        sut.handle(.getDomains)
        await MainActorTestWait.waitUntil { !sut.state.isLoading }

        #expect(sut.state.domains.isEmpty)
        switch sut.state.error {
        case .some(.networkUnavailable):
            break
        default:
            Issue.record("Expected networkUnavailable")
        }
    }

    @Test @MainActor
    func getAttributesForDomain_success_updatesTableAndFlags() async {
        let db = StubDatabaseRepository()
        let row = AttributeEntity(name: "r1", attributes: [.init(name: "c", value: "v")])
        db.attributesResult = PagedResult(items: [row], nextToken: "tok")
        let sut = Self.makeSUT(database: db)

        sut.handle(.getAttributesForDomain("dom"))
        await MainActorTestWait.waitUntil { sut.state.showAttributes }

        #expect(sut.state.showAttributes == true)
        #expect(sut.state.error == nil)
        #expect(sut.tabularViewModel.state.items.count == 1)
        #expect(sut.tabularViewModel.state.items.first?.name == "r1")
        #expect(db.lastFetchDomain == "dom")
    }

    @Test @MainActor
    func getAttributesForDomain_failure_setsError() async {
        let db = StubDatabaseRepository()
        db.fetchAttributesError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost)
        let sut = Self.makeSUT(database: db)

        sut.handle(.getAttributesForDomain("dom"))
        await MainActorTestWait.waitUntil { sut.state.error != nil }

        #expect(sut.state.showAttributes == false)
        switch sut.state.error {
        case .some(.networkUnavailable):
            break
        default:
            Issue.record("Expected networkUnavailable")
        }
    }

    @Test @MainActor
    func loadMoreAttributes_appendsItemsAndAdvancesToken() async {
        let db = StubDatabaseRepository()
        let p1 = PagedResult(items: [AttributeEntity(name: "a", attributes: [])], nextToken: "t1")
        let p2 = PagedResult(items: [AttributeEntity(name: "b", attributes: [])], nextToken: nil)
        db.attributePages = [p1, p2]
        let sut = Self.makeSUT(database: db)

        sut.handle(.getAttributesForDomain("dom"))
        await MainActorTestWait.waitUntil { sut.state.showAttributes }
        sut.handle(.loadMoreAttributes)
        await MainActorTestWait.waitUntil { sut.tabularViewModel.state.items.count == 2 }

        #expect(sut.tabularViewModel.state.items.map(\.name) == ["a", "b"])
        #expect(sut.state.isLoadingMore == false)
    }

    @Test @MainActor
    func loadMoreAttributes_withoutToken_noOp() async {
        let db = StubDatabaseRepository()
        db.attributesResult = PagedResult(items: [AttributeEntity(name: "a", attributes: [])], nextToken: nil)
        let sut = Self.makeSUT(database: db)

        sut.handle(.getAttributesForDomain("dom"))
        await MainActorTestWait.waitUntil { sut.state.showAttributes }
        sut.handle(.loadMoreAttributes)
        await Task.yield()

        #expect(sut.tabularViewModel.state.items.count == 1)
    }

    @Test @MainActor
    func runCustomQuery_success_setsItems() async {
        let db = StubDatabaseRepository()
        db.attributesResult = PagedResult(items: [AttributeEntity(name: "q", attributes: [])], nextToken: nil)
        let sut = Self.makeSUT(database: db)

        sut.handle(.getAttributesForDomain("dom"))
        await MainActorTestWait.waitUntil { sut.state.showAttributes }
        sut.handle(.runCustomQuery("select * from dom"))
        await MainActorTestWait.waitUntil { db.lastSelectExpression == "select * from dom" && sut.tabularViewModel.state.items.first?.name == "q" }

        #expect(sut.state.showAttributes == true)
        #expect(sut.tabularViewModel.state.error == nil)
    }

    @Test @MainActor
    func runCustomQuery_failure_setsTabularError() async {
        let db = StubDatabaseRepository()
        db.attributesResult = PagedResult(items: [AttributeEntity(name: "x", attributes: [])], nextToken: nil)
        let sut = Self.makeSUT(database: db)

        sut.handle(.getAttributesForDomain("dom"))
        await MainActorTestWait.waitUntil { sut.state.showAttributes }
        db.fetchAttributesError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        sut.handle(.runCustomQuery("select *"))

        await MainActorTestWait.waitUntil { sut.tabularViewModel.state.error != nil }

        #expect(sut.state.showAttributes == true)
        switch sut.tabularViewModel.state.error {
        case .some(.networkUnavailable):
            break
        default:
            Issue.record("Expected tabular networkUnavailable")
        }
    }

    @Test @MainActor
    func runCustomQuery_withoutCurrentDomain_noOp() async {
        let db = StubDatabaseRepository()
        let sut = Self.makeSUT(database: db)

        sut.handle(.runCustomQuery("select *"))

        await Task.yield()
        #expect(db.lastFetchDomain == nil)
    }

    @Test @MainActor
    func exportCSV_usesDomainAsFileNameWhenDomainSelected() async {
        let db = StubDatabaseRepository()
        db.attributesResult = PagedResult(items: [AttributeEntity(name: "r", attributes: [.init(name: "c", value: "1")])], nextToken: nil)
        let exportRepo = MockCSVFileRepository(result: .success(URL(fileURLWithPath: "/tmp/out.csv")))
        let sut = Self.makeSUT(database: db, exportRepository: exportRepo)

        sut.handle(.getAttributesForDomain("my-domain"))
        await MainActorTestWait.waitUntil { sut.state.showAttributes }
        sut.handle(.exportCSVForSharing)

        #expect(exportRepo.receivedFileName == "my-domain.csv")
        #expect(sut.state.shareFileURL != nil)
    }

    @Test @MainActor
    func clearShareFileURL_clearsState() async {
        let db = StubDatabaseRepository()
        db.attributesResult = PagedResult(items: [AttributeEntity(name: "r", attributes: [.init(name: "c", value: "v")])], nextToken: nil)
        let exportRepo = MockCSVFileRepository(result: .success(URL(fileURLWithPath: "/tmp/out.csv")))
        let sut = Self.makeSUT(database: db, exportRepository: exportRepo)

        sut.handle(.getAttributesForDomain("d"))
        await MainActorTestWait.waitUntil { sut.state.showAttributes }
        sut.handle(.exportCSVForSharing)
        #expect(sut.state.shareFileURL != nil)

        sut.handle(.clearShareFileURL)

        #expect(sut.state.shareFileURL == nil)
    }
}

private extension HomeViewModelTests {
    @MainActor
    static func makeSUT(
        database: StubDatabaseRepository,
        exportRepository: MockCSVFileRepository? = nil
    ) -> HomeViewModel {
        let exportRepo = exportRepository ?? MockCSVFileRepository(result: .success(URL(fileURLWithPath: "/tmp/default.csv")))
        let provider = DatabaseRepositoryProvider(initial: database)
        let secure = StubSecureStorageRepository()
        let unsecure = CapturingUnsecuredKeyValueStorage()
        let coordinator = CredentialsCoordinator(
            awsNewInstanceUseCase: AWSNewInstanceUseCase(repositoryProvider: provider, repositoryFactory: { StubDatabaseRepository() }),
            awsRegisterUseCase: AWSRegisterUseCase(repositoryProvider: provider),
            getCredentialsFromSecureStorageUseCase: GetCredentialFromSecureStorageUseCase(repository: secure),
            listStoredCredentialsUseCase: ListStoredCredentialsUseCase(secureStorageRepository: secure),
            storeCredentialsInSecureStorageUseCase: StoreCredentialsInSecureStorageUseCase(secureStorage: secure),
            setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: unsecure))
        let exportUseCase = ExportCSVToTemporaryFileUseCase(repository: exportRepo)
        return HomeViewModel(
            getDomainsListUseCase: AWSFetchDomainsUseCase(repositoryProvider: provider),
            awsGetAttributesUseCase: AWSFetchAttributesUseCase(repositoryProvider: provider),
            buildAttributesCSVUseCase: BuildAttributesCSVUseCase(),
            exportCSVToTemporaryFileUseCase: exportUseCase,
            getActiveProfileNameUseCase: GetActiveProfileNameUseCase(repositoryProvider: provider),
            coordinator: coordinator)
    }
}
