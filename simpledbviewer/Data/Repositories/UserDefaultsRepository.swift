//
//  UserDefaultsRepository.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-05.
//

import Foundation

final class UserDefaultsRepository: UnsecuredKeyValueStorageRepository {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func setValue(key: UnsecuredKeyValueStorageKeys, value: String) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    func getValue(for key: UnsecuredKeyValueStorageKeys) -> String? {
        userDefaults.string(forKey: key.rawValue)
    }
}
