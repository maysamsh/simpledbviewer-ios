//
//  NoDatabaseRepository.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-14.
//

import Foundation

final class TemporaryCSVFileRepository: CSVFileRepository {
    private let fileManager: FileManager
    private let directoryURL: URL

    init(fileManager: FileManager = .default,
         directoryURL: URL? = nil) {
        self.fileManager = fileManager
        self.directoryURL = directoryURL ?? fileManager.temporaryDirectory
    }

    func writeToTemporaryFile(csvContent: String, fileName: String) throws -> URL {
        let fileURL = directoryURL.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
        try Data(csvContent.utf8).write(to: fileURL, options: .atomic)
        return fileURL
    }
}
