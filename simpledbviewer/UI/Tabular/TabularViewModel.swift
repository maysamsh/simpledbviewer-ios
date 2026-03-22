//
//  TabularViewModel.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-10.
//

import Foundation
import Combine

@MainActor
final class TabularViewModel: ObservableObject {
    struct State {
        var items: [AttributeEntity] = []
        var columnNames: [String] = []
        var error: AppError?
    }

    enum Action {
        case setItems([AttributeEntity])
        case appendItems([AttributeEntity])
        case setError(AppError?)
    }

    @Published private(set) var state = State()
    private let buildAttributesCSVUseCase: BuildAttributesCSVUseCase

    init(buildAttributesCSVUseCase: BuildAttributesCSVUseCase) {
        self.buildAttributesCSVUseCase = buildAttributesCSVUseCase
    }

    func handle(_ action: Action) {
        switch action {
        case .setItems(let items):
            state.items = items
            state.columnNames = computeColumnNames(from: items)
            state.error = nil
        case .appendItems(let newItems):
            state.items.append(contentsOf: newItems)
            state.columnNames = computeColumnNames(from: state.items)
        case .setError(let error):
            state.error = error
            if error != nil {
                state.items = []
                state.columnNames = []
            }
        }
    }

    func buildCSV() -> String {
        let itemNameColumn = String(localized: "Item Name")
        let rows = state.items.map { item in
            [AttributeEntity.Attribute(name: itemNameColumn, value: item.name)] + item.attributes
        }
        return buildAttributesCSVUseCase.execute(columnNames: state.columnNames, rows: rows)
    }

    private func computeColumnNames(from items: [AttributeEntity]) -> [String] {
        let itemNameColumn = String(localized: "Item Name")
        var seen: Set<String> = [itemNameColumn]
        var names: [String] = [itemNameColumn]
        for item in items {
            for attr in item.attributes {
                if seen.insert(attr.name).inserted {
                    names.append(attr.name)
                }
            }
        }
        return names
    }
}
