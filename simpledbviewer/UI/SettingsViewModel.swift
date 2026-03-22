//
//  SettingsViewModel.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-19.
//

import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    private enum LimitRules {
        static let fallback = 100
        static let min = 1
        static let max = 2500
    }

    enum ContentState {
        case loading
        case ready([AWSCredentialNameEntity])
        case empty
        case error(AppError)
    }

    struct State {
        var contentState: ContentState = .loading
        var limitText: String = "\(LimitRules.fallback)"
        var limitValidationMessage: String?
    }

    enum Action {
        case load
        case delete(AWSCredentialNameEntity)
        case updateLimitText(String)
        case submitLimit
    }

    @Published private(set) var state = State()

    private let listCredentialsUseCase: ListStoredCredentialsUseCase
    private let deleteCredentialUseCase: DeleteCredentialUseCase
    private let getUnsecuredKeyValueUseCase: GetUnsecuredKeyValueUseCase
    private let setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase
    private var lastValidLimit: Int = LimitRules.fallback

    init(listCredentialsUseCase: ListStoredCredentialsUseCase,
         deleteCredentialUseCase: DeleteCredentialUseCase,
         getUnsecuredKeyValueUseCase: GetUnsecuredKeyValueUseCase,
         setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase) {
        self.listCredentialsUseCase = listCredentialsUseCase
        self.deleteCredentialUseCase = deleteCredentialUseCase
        self.getUnsecuredKeyValueUseCase = getUnsecuredKeyValueUseCase
        self.setUnsecuredKeyValueUseCase = setUnsecuredKeyValueUseCase
    }

    func handle(_ action: Action) {
        switch action {
        case .load:
            fetchCredentials()
            loadQueryDefaultLimit()
        case .delete(let entity):
            deleteCredential(entity)
        case .updateLimitText(let text):
            state.limitText = text
            state.limitValidationMessage = nil
        case .submitLimit:
            submitLimit()
        }
    }

    private func fetchCredentials() {
        do {
            let credentials = try listCredentialsUseCase.execute()
            state.contentState = credentials.isEmpty ? .empty : .ready(credentials)
        } catch {
            state.contentState = .error(AppErrorMapper.map(error))
        }
    }

    private func deleteCredential(_ entity: AWSCredentialNameEntity) {
        do {
            try deleteCredentialUseCase.execute(id: entity.id)
            fetchCredentials()
        } catch {
            state.contentState = .error(AppErrorMapper.map(error))
        }
    }

    private func loadQueryDefaultLimit() {
        let loadedLimit = parseValidLimit(getUnsecuredKeyValueUseCase.execute(key: .queryDefaultLimit)) ?? LimitRules.fallback
        lastValidLimit = loadedLimit
        state.limitText = String(loadedLimit)
        state.limitValidationMessage = nil
    }

    private func submitLimit() {
        guard let validLimit = parseValidLimit(state.limitText) else {
            state.limitValidationMessage = String(
                format: String(localized: "Limit must be between %lld and %lld."),
                Int64(LimitRules.min),
                Int64(LimitRules.max)
            )
            state.limitText = String(lastValidLimit)
            return
        }

        setUnsecuredKeyValueUseCase.execute(key: .queryDefaultLimit, value: String(validLimit))
        lastValidLimit = validLimit
        state.limitText = String(validLimit)
        state.limitValidationMessage = nil
    }

    private func parseValidLimit(_ value: String?) -> Int? {
        guard let value, let parsed = Int(value), (LimitRules.min...LimitRules.max).contains(parsed) else { return nil }
        return parsed
    }
}
