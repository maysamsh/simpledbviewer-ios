//
//  AWSNewInstanceUseCase.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-11.
//

final class AWSNewInstanceUseCase {
    private let repositoryProvider: DatabaseRepositoryProvider
    private let repositoryFactory: () -> DatabaseRepository
    
    init(repositoryProvider: DatabaseRepositoryProvider,
         repositoryFactory: @escaping () -> DatabaseRepository) {
        self.repositoryProvider = repositoryProvider
        self.repositoryFactory = repositoryFactory
    }
    
    func execute() {
        repositoryProvider.current = repositoryFactory()
    }
}
