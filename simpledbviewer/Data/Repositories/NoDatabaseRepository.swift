//
//  NoDatabaseRepository.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-04.
//

final class NoDatabaseRepository: DatabaseRepository {
    private(set) var profileName: String? = "nil"
    func register(accessKey: String, secretKey: String, region: SimpleDBRegionsRepository) throws {
        throw AppError.authFailure
    }
    
    func listDomains() async throws -> [String] {
        throw AppError.noCredentials
    }

    func fetchAttributes(domainName: String, nextToken: String?, selectExpression: String?) async throws -> PagedResult<AttributeEntity> {
        return PagedResult(items: [], nextToken: nil)
    }
    
    func updateProfileName(_ name: String?) { }
}
