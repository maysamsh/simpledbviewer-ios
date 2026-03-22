//
//  NoDatabaseRepository.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-14.
//

import Foundation

final class ExportCSVToTemporaryFileUseCase {
    private let repository: CSVFileRepository

    init(repository: CSVFileRepository) {
        self.repository = repository
    }

    func execute(csvContent: String, fileName: String = "report.csv") throws -> URL {
        try repository.writeToTemporaryFile(csvContent: csvContent, fileName: fileName)
    }
}
