import Foundation
import Testing
@testable import simpledbviewer

struct AWSAndSetupUseCaseTests {
    @Test
    func awsNewInstance_replacesCurrentRepository() {
        let first = StubDatabaseRepository()
        let second = StubDatabaseRepository()
        let provider = DatabaseRepositoryProvider(initial: first)
        let sut = AWSNewInstanceUseCase(repositoryProvider: provider, repositoryFactory: { second })

        sut.execute()

        #expect(ObjectIdentifier(provider.current as AnyObject) == ObjectIdentifier(second as AnyObject))
    }

    @Test
    func awsRegister_success_callsRegisterAndProfileName() throws {
        let stub = StubDatabaseRepository()
        let provider = DatabaseRepositoryProvider(initial: stub)
        let sut = AWSRegisterUseCase(repositoryProvider: provider)

        try sut.execute(accessKey: "ak", secretKey: "sk", region: .usEast1, profileName: "Prof")

        #expect(stub.lastRegister?.0 == "ak")
        #expect(stub.lastRegister?.1 == "sk")
        #expect(stub.lastRegister?.2 == .usEast1)
        #expect(stub.profileName == "Prof")
    }

    @Test
    func awsRegister_failure_mapsToAppError() {
        let stub = StubDatabaseRepository()
        stub.registerError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        let provider = DatabaseRepositoryProvider(initial: stub)
        let sut = AWSRegisterUseCase(repositoryProvider: provider)

        do {
            try sut.execute(accessKey: "a", secretKey: "b", region: .usEast1, profileName: nil)
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

    @Test @MainActor
    func awsFetchDomains_success() async throws {
        let stub = StubDatabaseRepository(domains: ["d1", "d2"])
        let provider = DatabaseRepositoryProvider(initial: stub)
        let sut = AWSFetchDomainsUseCase(repositoryProvider: provider)

        let list = try await sut.execute()

        #expect(list == ["d1", "d2"])
    }

    @Test @MainActor
    func awsFetchDomains_failure_mapsError() async {
        let stub = StubDatabaseRepository()
        stub.listDomainsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost)
        let provider = DatabaseRepositoryProvider(initial: stub)
        let sut = AWSFetchDomainsUseCase(repositoryProvider: provider)

        do {
            _ = try await sut.execute()
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

    @Test @MainActor
    func awsFetchAttributes_returnsRepositoryPage() async throws {
        let item = AttributeEntity(name: "row", attributes: [.init(name: "c", value: "v")])
        let page = PagedResult(items: [item], nextToken: "next")
        let stub = StubDatabaseRepository(attributesResult: page)
        let provider = DatabaseRepositoryProvider(initial: stub)
        let sut = AWSFetchAttributesUseCase(repositoryProvider: provider)

        let result = try await sut.execute(domain: "my-domain", nextToken: "tok", selectExpression: "select")

        #expect(result.items.count == 1)
        #expect(result.items.first?.name == "row")
        #expect(result.nextToken == "next")
        #expect(stub.lastFetchDomain == "my-domain")
        #expect(stub.lastFetchToken == "tok")
        #expect(stub.lastSelectExpression == "select")
    }

    @Test
    func getActiveProfileName_readsFromCurrentRepository() {
        let stub = StubDatabaseRepository()
        stub.profileName = "Active"
        let provider = DatabaseRepositoryProvider(initial: stub)
        let sut = GetActiveProfileNameUseCase(repositoryProvider: provider)

        #expect(sut.execute() == "Active")
    }

    @Test
    func setupRecent_emptyCredentials_doesNotRegister() throws {
        let (sut, holder) = makeSetupSUT(credentials: [], latestId: nil)

        try sut.execute()

        #expect(holder.instance == nil)
    }

    @Test
    func setupRecent_invalidLatestId_usesLastCredential() throws {
        let a = AWSCredentialNameEntity(id: "a", displayName: "A")
        let b = AWSCredentialNameEntity(id: "b", displayName: "B")
        let accountB = AWSCredentialEntity(id: "b", displayName: "B", region: "us-east-1", accessKey: "kb", secretKey: "ks")
        let (sut, holder) = makeSetupSUT(
            credentials: [a, b],
            latestId: "missing",
            fetchById: ["b": accountB])

        try sut.execute()

        #expect(holder.instance?.lastRegister?.0 == "kb")
    }

    @Test
    func setupRecent_success_registersWithFetchedAccount() throws {
        let credName = AWSCredentialNameEntity(id: "id1", displayName: "N")
        let account = AWSCredentialEntity(id: "id1", displayName: "N", region: "us-west-1", accessKey: "ka", secretKey: "ks")
        let (sut, holder) = makeSetupSUT(
            credentials: [credName],
            latestId: "id1",
            fetchById: ["id1": account])

        try sut.execute()

        #expect(holder.instance?.lastRegister?.0 == "ka")
        #expect(holder.instance?.lastRegister?.1 == "ks")
        #expect(holder.instance?.lastRegister?.2 == .usWest1)
        #expect(holder.instance?.profileName == "N")
    }

    @Test
    func setupRecent_invalidRegion_doesNotRegister() throws {
        let credName = AWSCredentialNameEntity(id: "id1", displayName: "N")
        let account = AWSCredentialEntity(id: "id1", displayName: "N", region: "not-a-region", accessKey: "ka", secretKey: "ks")
        let (sut, holder) = makeSetupSUT(
            credentials: [credName],
            latestId: "id1",
            fetchById: ["id1": account])

        try sut.execute()

        #expect(holder.instance == nil)
    }

    @Test
    func exportCSVToTemporaryFile_delegatesToRepository() throws {
        let expected = URL(fileURLWithPath: "/tmp/out.csv")
        let repo = MockCSVFileRepository(result: .success(expected))
        let sut = ExportCSVToTemporaryFileUseCase(repository: repo)

        let url = try sut.execute(csvContent: "a,b", fileName: "out.csv")

        #expect(url == expected)
        #expect(repo.receivedCSVContent == "a,b")
        #expect(repo.receivedFileName == "out.csv")
    }
}

private extension AWSAndSetupUseCaseTests {
    func makeSetupSUT(
        credentials: [AWSCredentialNameEntity],
        latestId: String?,
        fetchById: [String: AWSCredentialEntity] = [:]
    ) -> (SetupRecentRepositoryUseCase, LatestActivatedDatabaseRepository) {
        let holder = LatestActivatedDatabaseRepository()
        let provider = DatabaseRepositoryProvider(initial: StubDatabaseRepository())
        let secure = StubSecureStorageRepository(credentialsList: credentials, fetchById: fetchById)
        let unsecure = CapturingUnsecuredKeyValueStorage(latestAddedId: latestId)
        let register = AWSRegisterUseCase(repositoryProvider: provider)
        let sut = SetupRecentRepositoryUseCase(
            repositoryProvider: provider,
            secureStorageRepository: secure,
            unsecuredKeyValueStorageRepository: unsecure,
            awsRegisterUseCase: register,
            repositoryFactory: {
                let s = StubDatabaseRepository()
                holder.instance = s
                return s
            })
        return (sut, holder)
    }
}
