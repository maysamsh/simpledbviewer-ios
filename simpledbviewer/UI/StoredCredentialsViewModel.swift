//
//  StoredCredentialsViewModel.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-06.
//

import Foundation
import Combine

@MainActor
final class StoredCredentialsViewModel: ObservableObject {
    enum ContentState {
        case loading
        case ready([AWSCredentialNameEntity])
        case empty
        case error(AppError)
    }
    
    struct State {
        var contentState: ContentState = .loading
    }
    
    enum Action {
        case load
        case select(AWSCredentialNameEntity)
    }
    
    @Published private(set) var state = State()
    let profileSelected = PassthroughSubject<AWSCredentialNameEntity, Never>()

    private let storedCredentialsUseCase: ListStoredCredentialsUseCase
    private let setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase
    
    init(storedCredentialsUseCase: ListStoredCredentialsUseCase,
         setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase) {
        self.storedCredentialsUseCase = storedCredentialsUseCase
        self.setUnsecuredKeyValueUseCase = setUnsecuredKeyValueUseCase
    }
    
    func handle(_ action: Action) {
        switch action {
        case .load:
            fetchProfiles()
        case .select(let id):
            setUnsecuredKeyValueUseCase.execute(key: .latestAddedId, value: id.id)
            profileSelected.send(id)
        }
    }
    
    private func fetchProfiles() {
        do {
            let profiles = try storedCredentialsUseCase.execute()
            if profiles.isEmpty {
                state.contentState = .empty
            } else {
                state.contentState = .ready(profiles)
            }
        } catch {
            state.contentState = .error(AppErrorMapper.map(error))
        }
    }
}

