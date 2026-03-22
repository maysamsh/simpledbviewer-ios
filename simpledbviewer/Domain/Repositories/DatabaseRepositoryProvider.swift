//
//  DatabaseRepositoryProvider.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-05.

/// Shared mutable holder for the currently active database repository.
/// Injected into use cases so they always read the latest connection.
final class DatabaseRepositoryProvider {
    var current: DatabaseRepository

    init(initial: DatabaseRepository) {
        self.current = initial
    }
}
