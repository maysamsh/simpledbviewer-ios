//
//  AttributesView.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-13.
//

import SwiftUI

struct AttributesView: View {
    @Binding var showAttributes: Bool
    @Binding var shareFileURL: URL?
    let tabularViewModel: TabularViewModel
    let loadMoreAttributes: () -> Void
    let exportCSVForSharing: () -> Void
    let showCustomSQL: () -> Void
    let clearShareFileURL: () -> Void
    private let viewModel: AttributesViewModel

    init(showAttributes: Binding<Bool>,
         shareFileURL: Binding<URL?>,
         tabularViewModel: TabularViewModel,
         loadMoreAttributes: @escaping () -> Void,
         exportCSVForSharing: @escaping () -> Void,
         showCustomSQL: @escaping () -> Void,
         clearShareFileURL: @escaping () -> Void) {
        self._showAttributes = showAttributes
        self._shareFileURL = shareFileURL
        self.tabularViewModel = tabularViewModel
        self.loadMoreAttributes = loadMoreAttributes
        self.exportCSVForSharing = exportCSVForSharing
        self.showCustomSQL = showCustomSQL
        self.clearShareFileURL = clearShareFileURL
        self.viewModel = AttributesViewModel(tabularViewModel: tabularViewModel, shareFileURL: shareFileURL.wrappedValue)
    }
    
    var body: some View {
        VStack {
            if showAttributes {
                TabularView(viewModel: tabularViewModel, evenRowColor: Color(UIColor.systemBackground), oddRowColor: Color(UIColor.secondarySystemBackground)) {
                    loadMoreAttributes()
                }
            } else {
                Text("Select a domain")
                    .foregroundStyle(.secondary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    exportCSVForSharing()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .scaledToFit()
                        .accessibilityHidden(true)
                }
                .disabled(tabularViewModel.state.items.isEmpty || !showAttributes)
                .accessibilityLabel("Share CSV report")
                .accessibilityHint("Exports and opens the sharing screen for report file")
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    showCustomSQL()
                } label: {
                    Image(systemName: "wand.and.rays")
                        .scaledToFit()
                        .accessibilityHidden(true)
                }
                .disabled(!showAttributes)
                .accessibilityLabel(L10n.customSQL)
                .accessibilityHint(L10n.opensTheScreenToRunACustomQuery)
                .accessibilityIdentifier("customSQLToolbarButton")
            }
        }
        .sheet(isPresented: shareSheetIsPresentedBinding) {
            NavigationStack {
                VStack(spacing: Spacing.md2) {
                    Text(viewModel.shareSheetDescription)
                        .font(.body)
                    if let shareFileURL {
                        ShareLink(item: shareFileURL) {
                            Label("Share CSV", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityHint("Opens the system share sheet for report")
                    }
                }
                .padding(Spacing.md2)
                .navigationTitle(String(format: String(localized: "Share %@"), viewModel.reportFileName))
                .presentationDetents([.medium])
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            clearShareFileURL()
                        }
                        .accessibilityHint("Closes the share sheet")
                    }
                }
            }
        }
    }

    private var shareSheetIsPresentedBinding: Binding<Bool> {
        Binding(
            get: { shareFileURL != nil },
            set: { isPresented in
                if !isPresented {
                    clearShareFileURL()
                }
            })
    }
}
