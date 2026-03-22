//
//  GetDomainsUseCase.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-04.
//
import Foundation

final class AWSFetchDomainsUseCase {
    private let repositoryProvider: DatabaseRepositoryProvider

    init(repositoryProvider: DatabaseRepositoryProvider) {
        self.repositoryProvider = repositoryProvider
    }

    func execute() async throws -> [String] {
        do {
            return try await repositoryProvider.current.listDomains()
        } catch {
            throw AppErrorMapper.map(error)
        }
    }
}
