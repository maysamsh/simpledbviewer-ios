//
//  AttributesViewModel.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-13.
//
import Foundation

@MainActor
struct AttributesViewModel {
    private let tabularViewModel: TabularViewModel
    private let shareFileURL: URL?

    init(tabularViewModel: TabularViewModel, shareFileURL: URL?) {
        self.tabularViewModel = tabularViewModel
        self.shareFileURL = shareFileURL
    }

    var reportFileName: String {
        shareFileURL?.lastPathComponent ?? "report.csv"
    }

    var shareSheetDescription: String {
        let recordsCount = tabularViewModel.state.items.count
        if let fileSizeText {
            return String(
                format: String(localized: "%@ is ready to share. It contains %lld records and is %@."),
                reportFileName,
                Int64(recordsCount),
                fileSizeText
            )
        }
        return String(
            format: String(localized: "%@ is ready to share. It contains %lld records."),
            reportFileName,
            Int64(recordsCount)
        )
    }

    private var fileSizeText: String? {
        guard let shareFileURL else { return nil }
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: shareFileURL.path),
              let fileSize = attributes[.size] as? NSNumber else { return nil }
        return ByteCountFormatter.string(fromByteCount: fileSize.int64Value, countStyle: .file)
    }
}
