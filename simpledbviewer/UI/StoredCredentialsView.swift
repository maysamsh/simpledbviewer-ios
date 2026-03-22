//
//  StoredCredentialsView.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-06.
//

import SwiftUI

struct StoredCredentialsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StoredCredentialsViewModel
    
    var body: some View {
        VStack {
            switch viewModel.state.contentState {
            case .loading:
                Text("Loading")
                    .accessibilityLabel("Loading profiles")
            case .ready(let entities):
                List {
                    ForEach(entities) { entity in
                        Button {
                            viewModel.handle(.select(entity))
                            dismiss()
                        } label: {
                            Text(entity.displayName)
                        }
                        .accessibilityLabel(String(format: String(localized: "Select profile %@"), entity.displayName))
                        .accessibilityHint("Selects this profile and closes the list")

                    }
                }
            case .empty:
                ContentUnavailableView(
                    "No Profiles",
                    systemImage: "person.fill.badge.plus",
                    description: Text("You have not added any profiles yet.")
                )
                .accessibilityLabel(String(localized: "accessibility.no_profiles"))
            case .error(let appError):
                Text(String(format: String(localized: "Error: %@"), appError.localizedDescription))
                    .accessibilityLabel(String(format: String(localized: "Error: %@"), appError.localizedDescription))
            }
        }
        .task {
            viewModel.handle(.load)
        }
    }
}

#Preview {
    struct PreviewSecureStorage: SecureStorageRepository {
        func deleteAllCredentials() throws { }
        func listStoredCredentials() throws -> [AWSCredentialNameEntity] { [] }
        func fetchCredential(for id: String) throws -> AWSCredentialEntity { throw AppError.notFound(what: id) }
        func storeCredential(_ data: AWSCredentialEntity) throws {}
        func updateCredential(_ data: AWSCredentialEntity) throws {}
        func deleteCredential(for id: String) throws {}
    }
    struct PreviewUnsecuredStorage: UnsecuredKeyValueStorageRepository {
        func setValue(key: UnsecuredKeyValueStorageKeys, value: String) {}
        func getValue(for key: UnsecuredKeyValueStorageKeys) -> String? { nil }
    }
    let setUnsecuredKeyValueUseCase = SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: PreviewUnsecuredStorage())
    
    return StoredCredentialsView(
        viewModel: StoredCredentialsViewModel(
            storedCredentialsUseCase: ListStoredCredentialsUseCase(
                secureStorageRepository: PreviewSecureStorage()
            ),
            setUnsecuredKeyValueUseCase: setUnsecuredKeyValueUseCase))
}
