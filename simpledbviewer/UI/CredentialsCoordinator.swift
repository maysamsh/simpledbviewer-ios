//
//  CredentialsCoordinator.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-11.
//

import Foundation
import Combine

@MainActor
final class CredentialsCoordinator: ObservableObject {
    let didRegister = PassthroughSubject<Void, Never>()
    @Published private(set) var error: AppError?

    private var cancellables = Set<AnyCancellable>()
    private let awsNewInstanceUseCase: AWSNewInstanceUseCase
    private let awsRegisterUseCase: AWSRegisterUseCase
    private let getCredentialsFromSecureStorageUseCase: GetCredentialFromSecureStorageUseCase
    private let listStoredCredentialsUseCase: ListStoredCredentialsUseCase
    private let storeCredentialsInSecureStorageUseCase: StoreCredentialsInSecureStorageUseCase
    private let setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase

    lazy var storedListViewModel: StoredCredentialsViewModel = {
        let vm = StoredCredentialsViewModel(storedCredentialsUseCase: listStoredCredentialsUseCase,
                                            setUnsecuredKeyValueUseCase: setUnsecuredKeyValueUseCase)
        vm.profileSelected
            .sink { [weak self] id in self?.authenticate(with: id) }
            .store(in: &cancellables)
        return vm
    }()

    lazy var addCredentialsViewModel: AddAWSSecretsViewModel = {
        let vm = AddAWSSecretsViewModel(awsNewInstanceUseCase: awsNewInstanceUseCase,
                                        awsRegisterUseCase: awsRegisterUseCase,
                                        storeCredentialsInSecureStorageUseCase: storeCredentialsInSecureStorageUseCase,
                                        setUnsecuredKeyValueUseCase: setUnsecuredKeyValueUseCase)
        vm.profileAdded
            .sink { [weak self] in self?.didRegister.send() }
            .store(in: &cancellables)
        return vm
    }()

    init(awsNewInstanceUseCase: AWSNewInstanceUseCase,
         awsRegisterUseCase: AWSRegisterUseCase,
         getCredentialsFromSecureStorageUseCase: GetCredentialFromSecureStorageUseCase,
         listStoredCredentialsUseCase: ListStoredCredentialsUseCase,
         storeCredentialsInSecureStorageUseCase: StoreCredentialsInSecureStorageUseCase,
         setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase) {
        self.awsNewInstanceUseCase = awsNewInstanceUseCase
        self.awsRegisterUseCase = awsRegisterUseCase
        self.getCredentialsFromSecureStorageUseCase = getCredentialsFromSecureStorageUseCase
        self.listStoredCredentialsUseCase = listStoredCredentialsUseCase
        self.storeCredentialsInSecureStorageUseCase = storeCredentialsInSecureStorageUseCase
        self.setUnsecuredKeyValueUseCase = setUnsecuredKeyValueUseCase
    }

    private func authenticate(with id: AWSCredentialNameEntity) {
        do {
            let creds = try getCredentialsFromSecureStorageUseCase.execute(accountId: id.id)
            awsNewInstanceUseCase.execute()
            guard let region = SimpleDBRegionsRepository(rawValue: creds.region) else {
                error = .generic(
                    message: String(
                        format: String(localized: "Unknown region '%@'. Please re-add the profile."),
                        creds.region
                    )
                )
                return
            }
            try awsRegisterUseCase.execute(accessKey: creds.accessKey, secretKey: creds.secretKey, region: region, profileName: creds.displayName)
            didRegister.send()
        } catch {
            self.error = AppErrorMapper.map(error)
        }
    }
}
