//
//  NoDatabaseRepository.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-14.
//
import Foundation

protocol CSVFileRepository {
    func writeToTemporaryFile(csvContent: String, fileName: String) throws -> URL
}
