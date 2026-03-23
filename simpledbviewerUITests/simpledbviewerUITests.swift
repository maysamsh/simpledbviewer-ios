//
//  simpledbviewerUITests.swift
//  simpledbviewerUITests
//
//  Created by Maysam Shahsavari on 2026-02-27.
//

import UIKit
import XCTest

final class simpledbviewerUITests: XCTestCase {

    private let domainsLoadTimeout: TimeInterval = 90
    private let attributesLoadTimeout: TimeInterval = 90

    override func setUpWithError() throws {
        continueAfterFailure = false
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            XCUIDevice.shared.orientation = .landscapeLeft
        default:
            XCUIDevice.shared.orientation = .portrait
        }
    }

    override func tearDownWithError() throws {}

    /// Single launch for fastlane snapshot: use `only_testing` on this method to avoid 3× cold start + domain load per locale/device.
    /// Skipped in Xcode unless the scheme sets env `SIMPLEDBVIEWER_SNAPSHOT_SUITE=1` (Fastlane sets this when running screenshots lanes).
    @MainActor
    func testCaptureLocalizedScreenshots() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["SIMPLEDBVIEWER_SNAPSHOT_SUITE"] == "1",
            "Snapshot-only test; run `fastlane ios screenshots` or add SIMPLEDBVIEWER_SNAPSHOT_SUITE=1 to the UI test scheme environment."
        )
        let app = try launchAppForSnapshot()
        snapshot("01_DomainsList", timeWaitingForIdle: 0)

        let secondDomainRow = app.descendants(matching: .any).matching(identifier: "domainListRow.1").firstMatch
        guard secondDomainRow.waitForExistence(timeout: 5) else {
            throw XCTSkip("Requires at least two SimpleDB domains in the active profile.")
        }

        secondDomainRow.tap()

        let firstDataRow = app.descendants(matching: .any).matching(identifier: "tabularDataRow.0").firstMatch
        XCTAssertTrue(firstDataRow.waitForExistence(timeout: attributesLoadTimeout), "Expected attribute rows after selecting a domain.")
        snapshot("02_AttributesTable", timeWaitingForIdle: 0)

        let customSQLButton = app.buttons["customSQLToolbarButton"]
        XCTAssertTrue(customSQLButton.waitForExistence(timeout: 3), "Custom SQL toolbar button should be available when attributes are shown.")
        customSQLButton.tap()

        let customQueryScreen = app.descendants(matching: .any).matching(identifier: "customSQLQueryScreen").firstMatch
        XCTAssertTrue(customQueryScreen.waitForExistence(timeout: 3), "Custom query sheet should appear after opening custom SQL.")
        snapshot("03_CustomQuery", timeWaitingForIdle: 0)
    }

    @MainActor
    func testDomainsLoadAndListIsNotEmpty() throws {
        let app = try launchAppForSnapshot()
        snapshot("01_DomainsList", timeWaitingForIdle: 0)
        let secondDomainRow = app.descendants(matching: .any).matching(identifier: "domainListRow.1").firstMatch
        guard secondDomainRow.waitForExistence(timeout: 5) else {
            throw XCTSkip("Requires at least two SimpleDB domains in the active profile.")
        }
    }

    @MainActor
    func testSelectSecondDomainShowsNonEmptyAttributesTable() throws {
        let app = try launchAppForSnapshot()

        let secondDomainRow = app.descendants(matching: .any).matching(identifier: "domainListRow.1").firstMatch
        guard secondDomainRow.waitForExistence(timeout: 5) else {
            throw XCTSkip("Requires at least two SimpleDB domains in the active profile.")
        }

        secondDomainRow.tap()

        let firstDataRow = app.descendants(matching: .any).matching(identifier: "tabularDataRow.0").firstMatch
        XCTAssertTrue(firstDataRow.waitForExistence(timeout: attributesLoadTimeout), "Expected attribute rows after selecting a domain.")
        snapshot("02_AttributesTable", timeWaitingForIdle: 0)
    }

    @MainActor
    func testSelectSecondDomainThenOpenCustomSQL() throws {
        let app = try launchAppForSnapshot()

        let secondDomainRow = app.descendants(matching: .any).matching(identifier: "domainListRow.1").firstMatch
        guard secondDomainRow.waitForExistence(timeout: 5) else {
            throw XCTSkip("Requires at least two SimpleDB domains in the active profile.")
        }

        secondDomainRow.tap()

        let firstDataRow = app.descendants(matching: .any).matching(identifier: "tabularDataRow.0").firstMatch
        XCTAssertTrue(firstDataRow.waitForExistence(timeout: attributesLoadTimeout), "Expected attribute rows before using Custom SQL.")

        let customSQLButton = app.buttons["customSQLToolbarButton"]
        XCTAssertTrue(customSQLButton.waitForExistence(timeout: 3), "Custom SQL toolbar button should be available when attributes are shown.")
        customSQLButton.tap()

        let customQueryScreen = app.descendants(matching: .any).matching(identifier: "customSQLQueryScreen").firstMatch
        XCTAssertTrue(customQueryScreen.waitForExistence(timeout: 3), "Custom query sheet should appear after opening custom SQL.")
        snapshot("03_CustomQuery", timeWaitingForIdle: 0)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    private func launchAppForSnapshot() throws -> XCUIApplication {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        try selectDatabaseTabIfNeeded(in: app)
        waitForDomainsToLoad(in: app)
        return app
    }

    private func selectDatabaseTabIfNeeded(in app: XCUIApplication) throws {
        let databaseTab = app.tabBars.buttons["Database"]
        if databaseTab.waitForExistence(timeout: 3), databaseTab.isHittable {
            databaseTab.tap()
        }
    }

    private func waitForDomainsToLoad(in app: XCUIApplication) {
        let loading = app.descendants(matching: .any)["Loading domains"]
        if loading.waitForExistence(timeout: 3) {
            XCTAssertTrue(loading.waitForNonExistence(timeout: domainsLoadTimeout), "Domains should finish loading within \(domainsLoadTimeout) seconds.")
        }

        let firstDomainRow = app.descendants(matching: .any).matching(identifier: "domainListRow.0").firstMatch
        XCTAssertTrue(firstDomainRow.waitForExistence(timeout: domainsLoadTimeout), "Expected at least one domain after load (configure AWS profile and ensure domains exist).")
    }
}

private extension XCUIElement {
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if !exists {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        return !exists
    }
}
