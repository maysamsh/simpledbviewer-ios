//
//  SetUnsecuredKeyValueUseCase.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-11.
//

import Foundation

final class SetUnsecuredKeyValueUseCase {
    private let unsecuredKeyValueStorageRepository: UnsecuredKeyValueStorageRepository
    
    init(unsecuredKeyValueStorageRepository: UnsecuredKeyValueStorageRepository) {
        self.unsecuredKeyValueStorageRepository = unsecuredKeyValueStorageRepository
    }
    
    func execute(key: UnsecuredKeyValueStorageKeys, value: String) {
        unsecuredKeyValueStorageRepository.setValue(key: key, value: value)
    }
}

