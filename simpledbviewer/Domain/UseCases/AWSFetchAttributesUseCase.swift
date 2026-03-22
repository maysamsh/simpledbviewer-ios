//
//  AWSGetAttributesUseCase.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-10.
//

final class AWSFetchAttributesUseCase {
    private let repositoryProvider: DatabaseRepositoryProvider
    
    init(repositoryProvider: DatabaseRepositoryProvider) {
        self.repositoryProvider = repositoryProvider
    }
    
    func execute(domain: String, nextToken: String? = nil, selectExpression: String? = nil) async throws -> PagedResult<AttributeEntity> {
        try await repositoryProvider.current.fetchAttributes(domainName: domain, nextToken: nextToken, selectExpression: selectExpression)
    }
}
