//
//  AddAWSSecretsView.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-04.
//

import SwiftUI

struct AddAWSSecretsView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: AddAWSSecretsViewModel

    private var isCompact: Bool { horizontalSizeClass == .compact }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            formContent
            if let error = viewModel.state.error {
                ErrorView(error: error)
            }
        }
        .padding(.horizontal, isCompact ? Spacing.lg2 : Spacing.xl)
        .padding(.vertical, Spacing.lg2)
        .frame(maxWidth: isCompact ? nil : 420)
        .frame(maxWidth: .infinity)
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Profile Name")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField("Profile Name", text: profileNameBinding)
                .textFieldStyle(.roundedBorder)
                .textContentType(.username)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .accessibilityLabel("Profile Name")
            
            Text("Access Key")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField("Access Key", text: accessKeyBinding)
                .textFieldStyle(.roundedBorder)
                .textContentType(.username)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .accessibilityLabel("Access Key")

            Text("Secret access key")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField("Secret access key", text: secretKeyBinding)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
                .accessibilityLabel("Secret access key")

            Text("Region")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Picker("Region", selection: regionBinding) {
                ForEach(SimpleDBRegionsRepository.allCases, id: \.self) { region in
                    Text(region.displayName).tag(region)
                }
            }
            .pickerStyle(.menu)
            .accessibilityHint("Select the AWS region")

            Button {
                viewModel.handle(.authenticateAndSave)
            } label: {
                Text("Save")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, Spacing.md2)
            .accessibilityLabel("Save Profile")
            .accessibilityHint("Saves the AWS credentials for this profile")
        }
        .onChange(of: viewModel.state.dismiss) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }

    private var profileNameBinding: Binding<String> {
        Binding(
            get: { viewModel.state.profileName },
            set: { viewModel.handle(.updateProfileName($0)) }
        )
    }
    
    private var accessKeyBinding: Binding<String> {
        Binding(
            get: { viewModel.state.accessKey },
            set: { viewModel.handle(.updateAccessKey($0)) }
        )
    }

    private var secretKeyBinding: Binding<String> {
        Binding(
            get: { viewModel.state.secretKey },
            set: { viewModel.handle(.updateSecretKey($0)) }
        )
    }

    private var regionBinding: Binding<SimpleDBRegionsRepository> {
        Binding(
            get: { viewModel.state.region },
            set: { viewModel.handle(.updateRegion($0)) }
        )
    }
}

#Preview {
    struct PreviewSecureStorage: SecureStorageRepository {
        func deleteAllCredentials() throws {}
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
    let provider = DatabaseRepositoryProvider(initial: NoDatabaseRepository())
    let awsNewInstanceUseCase = AWSNewInstanceUseCase(repositoryProvider: provider) {
        NoDatabaseRepository()
    }
    let setUnsecuredKeyValueUseCase = SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: PreviewUnsecuredStorage())
    let storeCredentialsInSecureStorageUseCase = StoreCredentialsInSecureStorageUseCase(secureStorage: PreviewSecureStorage())
    
    let vm = AddAWSSecretsViewModel(awsNewInstanceUseCase: awsNewInstanceUseCase,
                                    awsRegisterUseCase: AWSRegisterUseCase(repositoryProvider: provider),
                                    storeCredentialsInSecureStorageUseCase: storeCredentialsInSecureStorageUseCase,
                                    setUnsecuredKeyValueUseCase: setUnsecuredKeyValueUseCase)

    return AddAWSSecretsView(viewModel: vm)
}
