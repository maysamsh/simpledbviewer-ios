//
//  CustomSQLViewModel.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-13.
//
import Foundation
import Combine

@MainActor
final class CustomSQLViewModel: ObservableObject {
    struct State {
        var queryText: String
        var validationError: String?
        var submittedQuery: String?

        var isSubmitDisabled: Bool {
            queryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    enum Action {
        case updateQuery(String)
        case submit
    }
    
    private let sqlQueryValidator: SimpleDBQueryValidatorType
    @Published private(set) var state: State

    init(sqlQueryValidator: SimpleDBQueryValidatorType,
         domain: String? = nil) {
        self.sqlQueryValidator = sqlQueryValidator
        if let domain {
            state = State(queryText: "select * from `\(domain)`")
        } else {
            state = State(queryText: "")
        }
    }

    func handle(_ action: Action) {
        switch action {
        case .updateQuery(let text):
            state.queryText = text
            state.validationError = nil
        case .submit:
            do {
                let sanitized = try sqlQueryValidator.sanitize(state.queryText)
                state.submittedQuery = sanitized
            } catch {
                state.validationError = error.localizedDescription
            }
        }
    }
}
