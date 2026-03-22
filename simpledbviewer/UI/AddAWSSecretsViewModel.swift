//
//  AddAWSSecretsViewModel.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-04.
//

import Foundation
import Combine

@MainActor
final class AddAWSSecretsViewModel: ObservableObject {
    struct State {
        var accessKey: String = ""
        var secretKey: String = ""
        var profileName: String = ""
        var region: SimpleDBRegionsRepository = .usEast1
        var dismiss: Bool = false
        var error: AppError?
    }
    
    enum Action {
        case updateAccessKey(String)
        case updateSecretKey(String)
        case updateProfileName(String)
        case updateRegion(SimpleDBRegionsRepository)
        case authenticateAndSave
    }
    
    private let awsRegisterUseCase: AWSRegisterUseCase
    private let awsNewInstanceUseCase: AWSNewInstanceUseCase
    private let storeCredentialsInSecureStorageUseCase: StoreCredentialsInSecureStorageUseCase
    private let setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase
    
    @Published private(set) var state = State()
    let profileAdded = PassthroughSubject<Void, Never>()
    
    init(awsNewInstanceUseCase: AWSNewInstanceUseCase,
         awsRegisterUseCase: AWSRegisterUseCase,
         storeCredentialsInSecureStorageUseCase: StoreCredentialsInSecureStorageUseCase,
         setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase) {
        self.awsRegisterUseCase = awsRegisterUseCase
        self.awsNewInstanceUseCase = awsNewInstanceUseCase
        self.storeCredentialsInSecureStorageUseCase = storeCredentialsInSecureStorageUseCase
        self.setUnsecuredKeyValueUseCase = setUnsecuredKeyValueUseCase
    }
    
    func handle(_ action: Action) {
        switch action {
        case .updateAccessKey(let string):
            state.accessKey = string
        case .updateSecretKey(let string):
            state.secretKey = string
        case .updateProfileName(let string):
            state.profileName = string
        case .updateRegion(let region):
            state.region = region
        case .authenticateAndSave:
            state.dismiss = false
            state.error = nil
            authenticateAndSave(accessKey: state.accessKey,
                                secret: state.secretKey,
                                region: state.region,
                                profile: state.profileName)
        }
    }
    
    private func authenticateAndSave(accessKey: String,
                                     secret: String,
                                     region: SimpleDBRegionsRepository,
                                     profile: String) {
        do {
            awsNewInstanceUseCase.execute()
            try authenticate(accessKey: accessKey,
                             secretKey: secret,
                             region: region)
            
            let account = AWSCredentialEntity(id: UUID().uuidString,
                                              displayName: profile,
                                              region: state.region.displayName,
                                              accessKey: accessKey,
                                              secretKey: secret)
            try storeCredentialsInSecureStorageUseCase.execute(account)
            setUnsecuredKeyValueUseCase.execute(key: .latestAddedId, value: account.id)
            profileAdded.send()
            state.dismiss = true
        } catch {
            state.dismiss = false
            state.error = AppErrorMapper.map(error)
        }
    }
    
    private func authenticate(accessKey: String, secretKey: String, region: SimpleDBRegionsRepository) throws {
        try awsRegisterUseCase.execute(accessKey: accessKey, secretKey: secretKey, region: region)
    }
}
