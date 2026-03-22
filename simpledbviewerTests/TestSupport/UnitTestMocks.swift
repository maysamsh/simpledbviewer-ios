import Foundation
import Testing
@testable import simpledbviewer

enum MainActorTestWait {
    @MainActor
    static func waitUntil(_ condition: () -> Bool, timeoutMs: Int = 5000) async {
        let limit = Date().addingTimeInterval(TimeInterval(timeoutMs) / 1000)
        while Date() < limit {
            if condition() { return }
            await Task.yield()
        }
        Issue.record("Timeout waiting for condition")
    }
}

final class MockCSVFileRepository: CSVFileRepository {
    enum Result {
        case success(URL)
        case failure(Error)
    }

    private let result: Result
    private(set) var receivedCSVContent: String?
    private(set) var receivedFileName: String?

    init(result: Result) {
        self.result = result
    }

    func writeToTemporaryFile(csvContent: String, fileName: String) throws -> URL {
        receivedCSVContent = csvContent
        receivedFileName = fileName
        switch result {
        case .success(let url):
            return url
        case .failure(let error):
            throw error
        }
    }
}

/// Configurable `DatabaseRepository` for tests (domains, attributes, register calls).
final class StubDatabaseRepository: DatabaseRepository {
    var profileName: String?
    private(set) var lastRegister: (String, String, SimpleDBRegionsRepository)?
    var registerError: Error?
    var domains: [String] = []
    var listDomainsError: Error?
    var attributesResult = PagedResult<AttributeEntity>(items: [], nextToken: nil)
    /// When non-empty, `fetchAttributes` returns pages in order (for load-more tests); otherwise uses `attributesResult`.
    var attributePages: [PagedResult<AttributeEntity>] = []
    private var attributePageIndex = 0
    var fetchAttributesError: Error?
    private(set) var lastFetchDomain: String?
    private(set) var lastFetchToken: String?
    private(set) var lastSelectExpression: String?

    init(domains: [String] = [], attributesResult: PagedResult<AttributeEntity>? = nil) {
        self.domains = domains
        if let attributesResult {
            self.attributesResult = attributesResult
        }
    }

    func register(accessKey: String, secretKey: String, region: SimpleDBRegionsRepository) throws {
        if let registerError { throw registerError }
        lastRegister = (accessKey, secretKey, region)
    }

    func listDomains() async throws -> [String] {
        if let listDomainsError { throw listDomainsError }
        return domains
    }

    func fetchAttributes(domainName: String, nextToken: String?, selectExpression: String?) async throws -> PagedResult<AttributeEntity> {
        if let fetchAttributesError { throw fetchAttributesError }
        lastFetchDomain = domainName
        lastFetchToken = nextToken
        lastSelectExpression = selectExpression
        if !attributePages.isEmpty {
            let i = min(attributePageIndex, attributePages.count - 1)
            let page = attributePages[i]
            if attributePageIndex < attributePages.count - 1 {
                attributePageIndex += 1
            }
            return page
        }
        return attributesResult
    }

    func updateProfileName(_ name: String?) {
        profileName = name
    }
}

final class LatestActivatedDatabaseRepository {
    var instance: StubDatabaseRepository?
}

final class StubSecureStorageRepository: SecureStorageRepository {
    var credentialsList: [AWSCredentialNameEntity] = []
    var fetchById: [String: AWSCredentialEntity] = [:]
    var listError: Error?
    var fetchResult: AWSCredentialEntity?
    var fetchError: Error?
    var storeError: Error?
    var deleteError: Error?
    private(set) var storedCredentials: [AWSCredentialEntity] = []
    private(set) var deletedIds: [String] = []
    private(set) var lastFetchId: String?

    init(credentialsList: [AWSCredentialNameEntity] = [],
        fetchById: [String: AWSCredentialEntity] = [:],
        listError: Error? = nil,
        fetchResult: AWSCredentialEntity? = nil,
        fetchError: Error? = nil,
        storeError: Error? = nil,
        deleteError: Error? = nil) {
        self.credentialsList = credentialsList
        self.fetchById = fetchById
        self.listError = listError
        self.fetchResult = fetchResult
        self.fetchError = fetchError
        self.storeError = storeError
        self.deleteError = deleteError
    }

    func listStoredCredentials() throws -> [AWSCredentialNameEntity] {
        if let listError { throw listError }
        return credentialsList
    }

    func fetchCredential(for id: String) throws -> AWSCredentialEntity {
        lastFetchId = id
        if let fetchError { throw fetchError }
        if let entity = fetchById[id] { return entity }
        if let fetchResult { return fetchResult }
        throw NSError(domain: "test", code: 1)
    }

    func storeCredential(_ data: AWSCredentialEntity) throws {
        if let storeError { throw storeError }
        storedCredentials.append(data)
    }

    func updateCredential(_ data: AWSCredentialEntity) throws {}

    func deleteCredential(for id: String) throws {
        if let deleteError { throw deleteError }
        deletedIds.append(id)
        credentialsList.removeAll { $0.id == id }
    }

    func deleteAllCredentials() throws {}
}

final class CapturingUnsecuredKeyValueStorage: UnsecuredKeyValueStorageRepository {
    var values: [UnsecuredKeyValueStorageKeys: String] = [:]

    init() {}

    init(latestAddedId: String?) {
        if let latestAddedId {
            values[.latestAddedId] = latestAddedId
        }
    }

    func setValue(key: UnsecuredKeyValueStorageKeys, value: String) {
        values[key] = value
    }

    func getValue(for key: UnsecuredKeyValueStorageKeys) -> String? {
        values[key]
    }
}

final class StubLegacyStorageRepository: LegacyStorageRepository {
    let credential: AWSCredentialEntity?
    private(set) var deleteLegacyDataCalled = false

    init(credential: AWSCredentialEntity?) {
        self.credential = credential
    }

    func fetchLegacyCredential() throws -> AWSCredentialEntity? {
        credential
    }

    func deleteLegacyData() throws {
        deleteLegacyDataCalled = true
    }
}

final class StubSQLQueryValidator: SimpleDBQueryValidatorType {
    var maxLimit: Int = 2500
    var sanitizeResult: Result<String, Error> = .success("sanitized")

    init() {}

    func sanitize(_ raw: String) throws -> String {
        try sanitizeResult.get()
    }
}
