//
//  AWSSimpleDBRepository.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-02.
//
import AWSSimpleDB

/// available endpoints: https://docs.aws.amazon.com/general/latest/gr/sdb.html#:~:text=Table_title:%20Service%20endpoints%20Table_content:%20header:%20%7C%20Region,sdb.sa%2Deast%2D1.amazonaws.com%20%7C%20Protocol:%20HTTP%20and%20HTTPS%20%7C
///
enum SimpleDBRegionsRepository: String, Hashable, CaseIterable {
    case usEast1 = "us-east-1"
    case usWest1 = "us-west-1"
    case usWest2 = "us-west-2"
    case apSouthEast1 = "ap-southeast-1"
    case apSouthEast2 = "ap-southeast-2"
    case apNorthEast1 = "ap-northeast-1"
    case saEast1 = "sa-east-1"
    
    var type: AWSRegionType {
        switch self {
        case .usEast1:
                .USEast1
        case .usWest1:
                .USWest1
        case .usWest2:
                .USWest2
        case .apSouthEast1:
                .APSoutheast1
        case .apSouthEast2:
                .APSoutheast2
        case .apNorthEast1:
                .APNortheast1
        case .saEast1:
                .SAEast1
        }
    }
    
    var displayName: String {
        return rawValue
    }
}

final class SimpleDBRepository: DatabaseRepository {
    private(set) var profileName: String?
    private let sqlQueryValidator: SimpleDBQueryValidatorType
    
    init(sqlQueryValidator: SimpleDBQueryValidatorType? = nil) {
        self.sqlQueryValidator = sqlQueryValidator ?? SimpleDBQueryValidator()
    }
    
    private lazy var simpleDb: AWSSimpleDB = .init()
    
    func register(accessKey: String, secretKey: String, region: SimpleDBRegionsRepository) throws {
        AWSSimpleDB.remove(forKey: region.displayName)

        let credentialProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        guard let configuration = AWSServiceConfiguration(region: region.type, credentialsProvider: credentialProvider) else {
            throw AppError.invalidConfiguration
        }
        
        AWSSimpleDB.register(with: configuration, forKey: region.displayName)
        self.simpleDb = AWSSimpleDB(forKey: region.displayName)
    }
    
    func listDomains() async throws -> [String] {
        guard let listDomainsRequest = AWSSimpleDBListDomainsRequest() else {
            throw AppError.invalidConfiguration
        }
        do {
            let response = try await simpleDb.listDomains(listDomainsRequest)
            return response.domainNames ?? []
        } catch {
            throw error
        }
    }
    
    func fetchAttributes(domainName: String, nextToken: String? = nil, selectExpression: String? = nil) async throws -> PagedResult<AttributeEntity> {
        guard let selectRequest = AWSSimpleDBSelectRequest() else {
            throw AppError.invalidConfiguration
        }
        let defaultStatement = String(format: "SELECT * FROM `%@`", domainName)
        let sanitezedDefaultStatement = try sqlQueryValidator.sanitize(defaultStatement)
        selectRequest.selectExpression = selectExpression ?? sanitezedDefaultStatement
        if let nextToken {
            selectRequest.nextToken = nextToken
        }
        let response = try await simpleDb.select(selectRequest)
        let items = (response.items ?? [])
            .compactMap { item -> AttributeEntity? in
                guard let name = item.name else {
                    return nil
                }
                let attributes = (item.attributes ?? [])
                    .compactMap { attribute in
                        if let name = attribute.name, let value = attribute.value {
                            return AttributeEntity.Attribute(name: name, value: value)
                        }
                        return nil
                    }
                return AttributeEntity(name: name, attributes: attributes)
            }
        return PagedResult(items: items, nextToken: response.nextToken)
    }
    
    func updateProfileName(_ name: String?) {
        self.profileName = name
    }
}
