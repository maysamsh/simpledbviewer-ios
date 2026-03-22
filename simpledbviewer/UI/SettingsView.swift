//
//  SettingsView.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-17.
//

import SwiftUI
import Combine
import UIKit

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @State private var entityToDelete: AWSCredentialNameEntity?
    @State private var keyboardBottomInset: CGFloat = 0
    @State private var keyboardFrame: CGRect = .zero
    @State private var limitFieldFrame: CGRect = .zero
    @State private var isLimitFieldEditing = false

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    switch viewModel.state.contentState {
                    case .loading:
                        ProgressView()
                            .padding(.vertical, Spacing.md)
                            .accessibilityLabel("Loading stored profiles")
                    case .ready(let entities):
                        ForEach(entities) { entity in
                            HStack {
                                Text(entity.displayName)
                                    .accessibilityLabel(String(format: String(localized: "Stored profile %@"), entity.displayName))
                                Spacer()
                                Button(action: {
                                    entityToDelete = entity
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                                .accessibilityLabel(String(format: String(localized: "Delete %@"), entity.displayName))
                            }
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                        }
                    case .empty:
                        Text("No profiles stored.")
                            .foregroundStyle(.secondary)
                            .accessibilityLabel(String(localized: "accessibility.no_profiles_stored"))
                    case .error(let appError):
                        Text(appError.localizedDescription)
                            .foregroundStyle(.red)
                            .accessibilityLabel(appError.localizedDescription)
                    }
                } header: {
                    Text("Stored Profiles")
                        .accessibilityAddTraits(.isHeader)
                }

                Section {
                    NumberPadAccessoryTextField(text: Binding(get: {
                        viewModel.state.limitText
                    }, set: { newValue in
                        viewModel.handle(.updateLimitText(newValue))
                    }), placeholder: String(localized: "Default query limit")) {
                        viewModel.handle(.submitLimit)
                    } onEditingChanged: { isEditing in
                        isLimitFieldEditing = isEditing
                        recalculateKeyboardInset()
                    } onFrameChanged: { frame in
                        limitFieldFrame = frame
                        recalculateKeyboardInset()
                    }
                    .accessibilityLabel("Default query limit")

                    Text("Allowed range: 0 to 2500")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, Spacing.sm)

                    if let validationMessage = viewModel.state.limitValidationMessage {
                        Text(validationMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding(.top, Spacing.sm)
                    }
                } header: {
                    Text("Query Builder")
                        .accessibilityAddTraits(.isHeader)
                }

                Section {
                    VStack(alignment: .leading, spacing: Spacing.md2) {
                        Text("Source code and project history are on GitHub. License terms are in the repository.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Link("github.com/maysamsh/simpledbviewer-ios", destination: URL(string: "https://github.com/maysamsh/simpledbviewer-ios")!)
                            .font(.footnote)
                        Text("With love from Toronto")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)
                } header: {
                    Text("Source Code")
                        .accessibilityAddTraits(.isHeader)
                }

                Section {
                    VStack(alignment: .leading, spacing: Spacing.md2) {
                        Text("This app uses the AWS SDK for Swift.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text("Licensed under the Apache License, Version 2.0.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Link("github.com/awslabs/aws-sdk-swift", destination: URL(string: "https://github.com/awslabs/aws-sdk-swift")!)
                            .font(.footnote)
                    }
                    .padding(.vertical, Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)
                } header: {
                    Text("Acknowledgments")
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .navigationTitle("Settings")
            .safeAreaInset(edge: .bottom) {
                Color.clear
                    .frame(height: keyboardBottomInset)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
                guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                keyboardFrame = frame
                recalculateKeyboardInset()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardFrame = .zero
                keyboardBottomInset = 0
            }
            .alert("Delete Profile", isPresented: .constant(entityToDelete != nil), presenting: entityToDelete) { entity in
                Button("Cancel", role: .cancel) {
                    entityToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let entity = entityToDelete {
                        withAnimation {
                            viewModel.handle(.delete(entity))
                        }
                        entityToDelete = nil
                    }
                }
            } message: { entity in
                Text(
                    String(
                        format: String(localized: "alert.delete_profile_confirmation"),
                        entity.displayName
                    )
                )
            }
            .task {
                viewModel.handle(.load)
            }
        }
    }

    private func recalculateKeyboardInset() {
        guard isLimitFieldEditing else {
            keyboardBottomInset = 0
            return
        }

        let overlap = limitFieldFrame.maxY - keyboardFrame.minY
        keyboardBottomInset = max(0, overlap + Spacing.md)
    }
}

#Preview {
    struct PreviewSecureStorage: SecureStorageRepository {
        func listStoredCredentials() throws -> [AWSCredentialNameEntity] {
            [AWSCredentialNameEntity(id: "1", displayName: "Production"),
             AWSCredentialNameEntity(id: "2", displayName: "Staging")]
        }
        func fetchCredential(for id: String) throws -> AWSCredentialEntity { throw AppError.notFound(what: id) }
        func storeCredential(_ data: AWSCredentialEntity) throws {}
        func updateCredential(_ data: AWSCredentialEntity) throws {}
        func deleteCredential(for id: String) throws {}
        func deleteAllCredentials() throws {}
    }
    let repo = PreviewSecureStorage()
    return SettingsView(
        viewModel: SettingsViewModel(
            listCredentialsUseCase: ListStoredCredentialsUseCase(secureStorageRepository: repo),
            deleteCredentialUseCase: DeleteCredentialUseCase(secureStorageRepository: repo),
            getUnsecuredKeyValueUseCase: GetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: UserDefaultsRepository()),
            setUnsecuredKeyValueUseCase: SetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: UserDefaultsRepository())
        )
    )
}

@MainActor
private struct NumberPadAccessoryTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let onDone: () -> Void
    let onEditingChanged: (Bool) -> Void
    let onFrameChanged: (CGRect) -> Void

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.placeholder = placeholder
        textField.keyboardType = .numberPad
        textField.delegate = context.coordinator
        context.coordinator.textField = textField
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textDidChange(_:)), for: .editingChanged)
        textField.addTarget(context.coordinator, action: #selector(Coordinator.editingDidBegin), for: .editingDidBegin)
        textField.addTarget(context.coordinator, action: #selector(Coordinator.editingDidEnd), for: .editingDidEnd)

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(systemItem: .flexibleSpace)
        let doneButton = UIBarButtonItem(title: String(localized: "Done"), style: .done, target: context.coordinator, action: #selector(Coordinator.doneTapped))
        toolbar.items = [flexibleSpace, doneButton]
        textField.inputAccessoryView = toolbar
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        context.coordinator.reportFrame()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onDone: onDone, onEditingChanged: onEditingChanged, onFrameChanged: onFrameChanged)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        private let onDone: () -> Void
        private let onEditingChanged: (Bool) -> Void
        private let onFrameChanged: (CGRect) -> Void
        weak var textField: UITextField?

        init(text: Binding<String>, onDone: @escaping () -> Void, onEditingChanged: @escaping (Bool) -> Void, onFrameChanged: @escaping (CGRect) -> Void) {
            _text = text
            self.onDone = onDone
            self.onEditingChanged = onEditingChanged
            self.onFrameChanged = onFrameChanged
        }

        @objc func textDidChange(_ sender: UITextField) {
            text = sender.text ?? ""
        }

        @objc func editingDidBegin() {
            onEditingChanged(true)
            reportFrame()
        }

        @objc func editingDidEnd() {
            onEditingChanged(false)
        }

        func reportFrame() {
            guard let textField, let window = textField.window else { return }
            let frame = textField.convert(textField.bounds, to: window)
            onFrameChanged(frame)
        }

        @objc func doneTapped() {
            onDone()
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
