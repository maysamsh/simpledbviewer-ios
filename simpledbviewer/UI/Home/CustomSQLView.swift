//
//  CustomSQLView.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-13.
//
import SwiftUI

struct CustomSQLView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CustomSQLViewModel
    var onSubmit: (String) -> Void

    init(sqlQueryValidator: SimpleDBQueryValidatorType = SimpleDBQueryValidator(),
         domain: String? = nil,
         onSubmit: @escaping (String) -> Void) {
        _viewModel = StateObject(wrappedValue: CustomSQLViewModel(sqlQueryValidator: sqlQueryValidator, domain: domain))
        self.onSubmit = onSubmit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md2) {
            TextEditor(text: queryBinding)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 120)
                .padding(Spacing.md)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: Spacing.md))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .accessibilityLabel("SQL query")
                .accessibilityHint("Enter a custom SQL query")

            if let error = viewModel.state.validationError {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .accessibilityLabel(error)
                    .accessibilityHint("Invalid SQL query")
            }

            Button("Run Query") {
                viewModel.handle(.submit)
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .disabled(viewModel.state.isSubmitDisabled)
            .accessibilityHint("Runs the custom query")
        }
        .padding(Spacing.lg)
        .navigationTitle("Custom Query")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .accessibilityHint("Closes the custom query screen")
            }
        }
        .onChange(of: viewModel.state.submittedQuery) { _, sql in
            guard let sql else { return }
            onSubmit(sql)
            dismiss()
        }
    }

    private var queryBinding: Binding<String> {
        Binding(
            get: { viewModel.state.queryText },
            set: { viewModel.handle(.updateQuery($0)) }
        )
    }
}
