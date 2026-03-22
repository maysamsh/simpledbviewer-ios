//
//  UnsecuredKeyValueStorageRepository.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-05.
//

enum UnsecuredKeyValueStorageKeys: String {
    case latestAddedId
    case migrationToV2
    case queryDefaultLimit
}

protocol UnsecuredKeyValueStorageRepository {
    func setValue(key: UnsecuredKeyValueStorageKeys, value: String)
    func getValue(for key: UnsecuredKeyValueStorageKeys) -> String?
}
