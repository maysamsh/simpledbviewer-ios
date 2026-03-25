//
//  HomeView.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-04.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var coordinator: CredentialsCoordinator
    
    enum SheetType {
        case none
        case addNewKeyIsPresented
        case profilesListIsPresented
        case customSQLIsPresented
    }
    
    @State private var visibility: NavigationSplitViewVisibility = .all
    @State private var sheetType: SheetType = .none
    @State private var selectedDomain: String?

    var body: some View {
        NavigationSplitView(sidebar: {
            VStack(spacing: .zero) {
                if let error = viewModel.state.error {
                    ErrorView(error: error)
                } else {
                    SidebarView(
                        domains: viewModel.state.domains,
                        isLoading: viewModel.state.isLoading,
                        isNotConfigured: viewModel.state.isNotConfigured,
                        profileName: viewModel.state.profileName,
                        selectedDomain: $selectedDomain
                    )
                }
            }
            .task {
                viewModel.handle(.getDomains)
            }
            .onChange(of: selectedDomain) { _, domain in
                guard let domain else { return }
                viewModel.handle(.getAttributesForDomain(domain))
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        sheetType = .profilesListIsPresented
                    } label: {
                        Image(systemName: "person.2.circle.fill")
                            .scaledToFit()
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Profiles")
                    .accessibilityHint("Opens the list of stored profiles")
                }

                ToolbarItem(placement: .automatic) {
                    Button {
                        sheetType = .addNewKeyIsPresented
                    } label: {
                        Image(systemName: "person.fill.badge.plus")
                            .scaledToFit()
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("Add Profile")
                    .accessibilityHint("Opens the screen to add a new profile")
                }
            }
            .sheet(isPresented: sheetTypeBinding , content: {
                NavigationStack {
                    switch sheetType {
                    case .none:
                        EmptyView()
                    case .addNewKeyIsPresented:
                        AddAWSSecretsView(viewModel: coordinator.addCredentialsViewModel)
                            .navigationTitle("Add a profile")
                            .toolbarTitleDisplayMode(.inline)
                            .presentationDetents([.medium, .large])
                    case .profilesListIsPresented:
                        StoredCredentialsView(viewModel: coordinator.storedListViewModel)
                            .navigationTitle("Select a profile")
                            .toolbarTitleDisplayMode(.inline)
                            .presentationDetents([.medium, .large])
                    case .customSQLIsPresented:
                        CustomSQLView(domain: selectedDomain) { sql in
                            viewModel.handle(.runCustomQuery(sql))
                        }
                        .presentationDetents([.medium, .large])
                    }
                }
            })
            .navigationTitle("Domains")
        }, detail: {
            AttributesView(showAttributes: showAttributesBinding,
                           shareFileURL: shareFileURLBinding,
                           tabularViewModel: viewModel.tabularViewModel,
                           loadMoreAttributes: { viewModel.handle(.loadMoreAttributes) },
                           exportCSVForSharing: { viewModel.handle(.exportCSVForSharing) },
                           showCustomSQL: { sheetType = .customSQLIsPresented },
                           clearShareFileURL: { viewModel.handle(.clearShareFileURL) })
        })
    }
    
    private var showAttributesBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.showAttributes },
            set: { _ in }
        )
    }
    
    private var sheetTypeBinding: Binding<Bool> {
        Binding(
            get: { sheetType != .none },
            set: { _ in sheetType = .none})
    }

    private var shareFileURLBinding: Binding<URL?> {
        Binding(
            get: { viewModel.state.shareFileURL },
            set: { newValue in
                if newValue == nil {
                    viewModel.handle(.clearShareFileURL)
                }
            })
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
    let previewSecureStorage = PreviewSecureStorage()

    let coordinator = CredentialsCoordinator(
        awsNewInstanceUseCase: AWSNewInstanceUseCase(repositoryProvider: provider) { NoDatabaseRepository() },
        awsRegisterUseCase: AWSRegisterUseCase(repositoryProvider: provider),
        getCredentialsFromSecureStorageUseCase: GetCredentialFromSecureStorageUseCase(repository: previewSecureStorage),
        listStoredCredentialsUseCase: ListStoredCredentialsUseCase(secureStorageRepository: previewSecureStorage),
        storeCredentialsInSecureStorageUseCase: StoreCredentialsInSecureStorageUseCase(secureStorage: previewSecureStorage),
        setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: PreviewUnsecuredStorage()))

    let viewModel = HomeViewModel(
        getDomainsListUseCase: AWSFetchDomainsUseCase(repositoryProvider: provider),
        awsGetAttributesUseCase: AWSFetchAttributesUseCase(repositoryProvider: provider),
        buildAttributesCSVUseCase: BuildAttributesCSVUseCase(),
        exportCSVToTemporaryFileUseCase: ExportCSVToTemporaryFileUseCase(repository: TemporaryCSVFileRepository()),
        getActiveProfileNameUseCase: GetActiveProfileNameUseCase(repositoryProvider: provider),
        coordinator: coordinator)

    return HomeView(viewModel: viewModel, coordinator: coordinator)
}
