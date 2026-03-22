//
//  SimpleDBQueryBuilderValidator.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-12.
//

import Foundation

enum SimpleDBQueryError: Error, LocalizedError {
    case emptyQuery
    case forbiddenStatement(String)
    case injectionDetected(String)
    case missingFromClause
    case unbalancedQuotes
    case unbalancedParentheses
    case invalidOperator(String)
    case limitExceeded(Int)

    var errorDescription: String? {
        switch self {
        case .emptyQuery:                   return "Query must not be empty."
        case .forbiddenStatement(let s):    return "Statement '\(s)' is not allowed. SimpleDB only supports SELECT."
        case .injectionDetected(let d):     return "Potential injection detected: \(d)"
        case .missingFromClause:            return "Query must include a FROM clause."
        case .unbalancedQuotes:             return "Query contains unbalanced single quotes."
        case .unbalancedParentheses:        return "Query contains unbalanced parentheses."
        case .invalidOperator(let op):      return "Operator '\(op)' is not supported by SimpleDB."
        case .limitExceeded(let n):         return "LIMIT \(n) exceeds SimpleDB's maximum of 2500."
        }
    }
}

protocol SimpleDBQueryValidatorType {
    var maxLimit: Int { get }
    func sanitize(_ raw: String) throws -> String
}

struct SimpleDBQueryValidator: SimpleDBQueryValidatorType {
    private enum LimitRules {
        static let fallback = 100
        static let min = 1
        static let max = 2500
    }
    
    let maxLimit = 2500
    private let getUnsecuredKeyValueUseCase: GetUnsecuredKeyValueUseCase
    
    private let forbiddenStatements = [
        "INSERT", "UPDATE", "DELETE", "DROP", "CREATE",
        "ALTER", "TRUNCATE", "REPLACE", "MERGE"
    ]

    // Operators SimpleDB does NOT support
    private let invalidOperators = ["||", "&&", "/*", "*/", "--"]

    // Allowed WHERE operators (for reference / future strict mode)
    private let validOperators = ["=", "!=", "<", ">", "<=", ">=", "LIKE", "NOT LIKE", "IN", "BETWEEN", "IS NULL", "IS NOT NULL", "INTERSECTION"]

    
    init(getUnsecuredKeyValueUseCase: GetUnsecuredKeyValueUseCase = GetUnsecuredKeyValueUseCase(unsecuredKeyValueStorageRepository: UserDefaultsRepository())) {
        self.getUnsecuredKeyValueUseCase = getUnsecuredKeyValueUseCase
    }
    
    /// Validates and sanitizes a SimpleDB SELECT query.
    /// - Parameter raw: The raw query string from user input.
    /// - Returns: A sanitized query string, or throws a `SimpleDBQueryError`.
    func sanitize(_ raw: String) throws -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw SimpleDBQueryError.emptyQuery }

        let upper = trimmed.uppercased()
        for forbidden in forbiddenStatements {
            if upper.hasPrefix(forbidden + " ") || upper.contains(" " + forbidden + " ") {
                throw SimpleDBQueryError.forbiddenStatement(forbidden)
            }
        }
        guard upper.hasPrefix("SELECT") else {
            throw SimpleDBQueryError.forbiddenStatement("non-SELECT")
        }

        if trimmed.contains("--") || trimmed.contains("/*") {
            throw SimpleDBQueryError.injectionDetected("SQL comment syntax")
        }

        let sanitized = escapeSingleQuotes(trimmed)

        guard upper.contains(" FROM ") else {
            throw SimpleDBQueryError.missingFromClause
        }

        let quoteCount = sanitized.filter { $0 == "'" }.count
        guard quoteCount % 2 == 0 else {
            throw SimpleDBQueryError.unbalancedQuotes
        }

        let openCount  = sanitized.filter { $0 == "(" }.count
        let closeCount = sanitized.filter { $0 == ")" }.count
        guard openCount == closeCount else {
            throw SimpleDBQueryError.unbalancedParentheses
        }

        for op in invalidOperators {
            if sanitized.contains(op) {
                throw SimpleDBQueryError.injectionDetected("unsupported operator '\(op)'")
            }
        }

        let finalQuery = try enforceLimitClause(sanitized, upper: sanitized.uppercased())

        return finalQuery
    }

    // MARK: - Helpers

    /// Escapes unescaped single quotes (apostrophes in values) by doubling them.
    private func escapeSingleQuotes(_ query: String) -> String {
        return query
            .replacingOccurrences(of: "''''", with: "''") /// prevent over-escaping
            .replacingOccurrences(of: "''", with: "\u{FFFD}")   /// temporarily mark valid pairs
            .replacingOccurrences(of: "\u{FFFD}", with: "''")   /// restore valid pairs
            .replacingOccurrences(of: "‘", with: "'")
            .replacingOccurrences(of: "’", with: "'")
    }

    /// Checks for an existing LIMIT clause and enforces the 2500 max.
    /// If no LIMIT is present, injects `LIMIT 100` as a safe default.
    private func enforceLimitClause(_ query: String, upper: String) throws -> String {
        let limitPattern = #"(?i)\bLIMIT\s+(\d+)\b"#
        let regex = try NSRegularExpression(pattern: limitPattern)
        let range = NSRange(query.startIndex..., in: query)

        if let match = regex.firstMatch(in: query, range: range),
           let numRange = Range(match.range(at: 1), in: query),
           let limitValue = Int(query[numRange]) {
            guard limitValue <= maxLimit else {
                throw SimpleDBQueryError.limitExceeded(limitValue)
            }
        } else {
            let defaultLimit = getUnsecuredKeyValueUseCase.execute(key: .queryDefaultLimit)
            let loadedLimit = parseValidLimit(defaultLimit) ?? LimitRules.fallback

            return query + " LIMIT \(loadedLimit)"
        }

        return query
    }
    
    private func parseValidLimit(_ value: String?) -> Int? {
        guard let value, let parsed = Int(value), (LimitRules.min...LimitRules.max).contains(parsed) else { return nil }
        return parsed
    }
}

// MARK: - Usage example
//
//do {
//    let raw = "select * from MyDomain where color = 'red' and size = 'large'"
//    let safe = try SimpleDBQueryValidator.sanitize(raw)
//    print("Safe query: \(safe)")
//} catch {
//    print("Validation failed: \(error.localizedDescription)")
//}
