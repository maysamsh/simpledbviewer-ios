//
//  DatabaseRepository.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-02.
//

protocol DatabaseRepository {
    var profileName: String? { get }
    func register(accessKey: String, secretKey: String, region: SimpleDBRegionsRepository) throws
    func listDomains() async throws -> [String]
    func fetchAttributes(domainName: String, nextToken: String?, selectExpression: String?) async throws -> PagedResult<AttributeEntity>
    func updateProfileName(_ name: String?)
}
