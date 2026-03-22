//
//  GetUnsecuredKeyValueUseCase.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-05.
//

import Foundation

final class GetUnsecuredKeyValueUseCase {
    private let unsecuredKeyValueStorageRepository: UnsecuredKeyValueStorageRepository
    
    init(unsecuredKeyValueStorageRepository: UnsecuredKeyValueStorageRepository) {
        self.unsecuredKeyValueStorageRepository = unsecuredKeyValueStorageRepository
    }
    
    func execute(key: UnsecuredKeyValueStorageKeys) -> String? {
        return unsecuredKeyValueStorageRepository.getValue(for: key)
    }
}
