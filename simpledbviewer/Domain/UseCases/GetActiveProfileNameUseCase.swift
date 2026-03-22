//
//  GetActiveProfileNameUseCase.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-19.
//

import Foundation

final class GetActiveProfileNameUseCase {
    private let repositoryProvider: DatabaseRepositoryProvider

    init(repositoryProvider: DatabaseRepositoryProvider) {
        self.repositoryProvider = repositoryProvider
    }

    func execute() -> String? {
        repositoryProvider.current.profileName
    }
}
