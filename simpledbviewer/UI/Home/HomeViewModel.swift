//
//  HomeViewModel.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-04.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    struct State {
        var domains: [String] = []
        var profileName: String?
        var isLoading = true
        var isLoadingMore = false
        var isNotConfigured = false
        var error: AppError?
        var showAttributes = false
        var shareFileURL: URL?
    }

    enum Action {
        case getDomains
        case getAttributesForDomain(String)
        case loadMoreAttributes
        case runCustomQuery(String)
        case exportCSVForSharing
        case clearShareFileURL
    }

    @Published private(set) var state = State()

    private let getDomainsListUseCase: AWSFetchDomainsUseCase
    private let awsGetAttributesUseCase: AWSFetchAttributesUseCase
    private let buildAttributesCSVUseCase: BuildAttributesCSVUseCase
    private let exportCSVToTemporaryFileUseCase: ExportCSVToTemporaryFileUseCase
    private let getActiveProfileNameUseCase: GetActiveProfileNameUseCase

    private var nextToken: String? = nil
    private var currentDomain: String? = nil
    private var cancellables = Set<AnyCancellable>()

    private(set) lazy var tabularViewModel = TabularViewModel(buildAttributesCSVUseCase: buildAttributesCSVUseCase)

    init(getDomainsListUseCase: AWSFetchDomainsUseCase,
         awsGetAttributesUseCase: AWSFetchAttributesUseCase,
         buildAttributesCSVUseCase: BuildAttributesCSVUseCase,
         exportCSVToTemporaryFileUseCase: ExportCSVToTemporaryFileUseCase,
         getActiveProfileNameUseCase: GetActiveProfileNameUseCase,
         coordinator: CredentialsCoordinator) {
        self.getDomainsListUseCase = getDomainsListUseCase
        self.awsGetAttributesUseCase = awsGetAttributesUseCase
        self.buildAttributesCSVUseCase = buildAttributesCSVUseCase
        self.exportCSVToTemporaryFileUseCase = exportCSVToTemporaryFileUseCase
        self.getActiveProfileNameUseCase = getActiveProfileNameUseCase

        coordinator.didRegister
            .sink { [weak self] in self?.handle(.getDomains) }
            .store(in: &cancellables)

        coordinator.$error
            .compactMap { $0 }
            .sink { [weak self] in self?.state.error = $0 }
            .store(in: &cancellables)
    }

    func handle(_ action: Action) {
        switch action {
        case .getDomains:
            state.error = nil
            state.isNotConfigured = false
            state.isLoading = true
            state.profileName = getActiveProfileNameUseCase.execute()
            Task {
                defer {
                    state.isLoading = false
                }
                do {
                    state.domains = try await getDomainsListUseCase.execute()
                } catch AppError.noCredentials {
                    state.domains = []
                    state.isNotConfigured = true
                } catch {
                    state.error = AppErrorMapper.map(error)
                    state.domains = []
                }
                
            }
        case .getAttributesForDomain(let domain):
            currentDomain = domain
            nextToken = nil
            state.showAttributes = false
            state.shareFileURL = nil
            tabularViewModel.handle(.setError(nil))
            Task {
                do {
                    let result = try await awsGetAttributesUseCase.execute(domain: domain)
                    tabularViewModel.handle(.setItems(result.items))
                    state.showAttributes = true
                    nextToken = result.nextToken
                } catch {
                    state.showAttributes = false
                    nextToken = nil
                    state.error = AppErrorMapper.map(error)
                }
            }
        case .loadMoreAttributes:
            guard let token = nextToken, let domain = currentDomain, !state.isLoadingMore else { return }
            state.isLoadingMore = true
            Task {
                do {
                    let result = try await awsGetAttributesUseCase.execute(domain: domain, nextToken: token)
                    tabularViewModel.handle(.appendItems(result.items))
                    nextToken = result.nextToken
                } catch {
                    state.error = AppErrorMapper.map(error)
                }
                state.isLoadingMore = false
            }
        case .runCustomQuery(let sql):
            guard let domain = currentDomain else { return }
            nextToken = nil
            state.showAttributes = true
            state.shareFileURL = nil
            tabularViewModel.handle(.setError(nil))
            Task {
                do {
                    let result = try await awsGetAttributesUseCase.execute(domain: domain, selectExpression: sql)
                    tabularViewModel.handle(.setItems(result.items))
                    state.showAttributes = true
                    nextToken = result.nextToken
                } catch {
                    state.showAttributes = true
                    nextToken = nil
                    tabularViewModel.handle(.setError(AppErrorMapper.map(error)))
                }
            }
        case .exportCSVForSharing:
            do {
                state.error = nil
                let csv = tabularViewModel.buildCSV()
                let reportName: String =
                if let currentDomain {
                    "\(currentDomain).csv"
                } else {
                    "report.csv"
                }
                state.shareFileURL = try exportCSVToTemporaryFileUseCase.execute(csvContent: csv, fileName: reportName)
            } catch {
                state.shareFileURL = nil
                state.error = AppErrorMapper.map(error)
            }
        case .clearShareFileURL:
            state.shareFileURL = nil
        }
    }

}
