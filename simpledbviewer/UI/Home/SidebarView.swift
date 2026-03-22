//
//  SidebarView.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-13.
//

import SwiftUI

struct SidebarView: View {
    let domains: [String]
    let isLoading: Bool
    let isNotConfigured: Bool
    let profileName: String?
    @Binding var selectedDomain: String?

    var body: some View {
        VStack(spacing: .zero) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel("Loading domains")
            } else if isNotConfigured {
                ContentUnavailableView(
                    "No Profile Added",
                    systemImage: "person.fill.badge.plus",
                    description: Text("Tap + to add your AWS credentials and get started.")
                )
            } else if domains.isEmpty {
                HomeEmptyView()
            } else {
                List(selection: $selectedDomain) {
                    if let profileName {
                        Section(
                            header: Text(profileName)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, Spacing.sm)) {
                                    domainRows
                                }
                                .listRowInsets(.init())
                        
                    } else {
                        Section {
                            domainRows
                        }
                        .listRowInsets(.init())
                    }
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var domainRows: some View {
        ForEach(Array(domains.enumerated()), id: \.offset) { index, domain in
            NavigationLink(value: domain) {
                Text(domain)
            }
            .tag(domain)
            .listRowBackground(Color.clear)
            .accessibilityIdentifier("domainListRow.\(index)")
            .accessibilityHint(String(format: String(localized: "Opens attributes for %@"), domain))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    SidebarView(domains: ["domain 1"], isLoading: false, isNotConfigured: false, profileName: "profile", selectedDomain: .constant("domain 1"))
}
