//
//  AuthenticateUseCase.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-04.
//

final class AWSRegisterUseCase {
    private let repositoryProvider: DatabaseRepositoryProvider
    
    init(repositoryProvider: DatabaseRepositoryProvider) {
        self.repositoryProvider = repositoryProvider
    }
    
    func execute(accessKey: String, secretKey: String, region: SimpleDBRegionsRepository, profileName: String? = nil) throws {
        do {
            try repositoryProvider.current.register(accessKey: accessKey, secretKey: secretKey, region: region)
            repositoryProvider.current.updateProfileName(profileName)
        } catch {
            throw AppErrorMapper.map(error)
        }
    }
}
