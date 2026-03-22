//
//  NoDatabaseRepository.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-15.
//

import Foundation

final class BuildAttributesCSVUseCase {
    func execute(columnNames: [String], rows: [[AttributeEntity.Attribute]]) -> String {
        guard !columnNames.isEmpty else { return "" }

        let header = columnNames.map(escapeCSVCell).joined(separator: ",")
        let dataRows = rows.map { attributes in
            let valuesByColumn = Dictionary(attributes.map { ($0.name, $0.value) }, uniquingKeysWith: { _, new in new })
            return columnNames
                .map { valuesByColumn[$0] ?? "" }
                .map(escapeCSVCell)
                .joined(separator: ",")
        }

        return ([header] + dataRows).joined(separator: "\n")
    }

    private func escapeCSVCell(_ value: String) -> String {
        let mustQuote = value.contains(",") || value.contains("\"") || value.contains("\n") || value.contains("\r")
        guard mustQuote else { return value }
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
