//
//  simpledbviewerUITests.swift
//  simpledbviewerUITests
//
//  Created by Maysam Shahsavari on 2026-02-27.
//

import XCTest

final class simpledbviewerUITests: XCTestCase {

    private let domainsLoadTimeout: TimeInterval = 90
    private let attributesLoadTimeout: TimeInterval = 90

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    @MainActor
    func testDomainsLoadAndListIsNotEmpty() throws {
        let app = XCUIApplication()
        app.launch()

        try selectDatabaseTabIfNeeded(in: app)
        waitForDomainsToLoad(in: app)
    }

    @MainActor
    func testSelectSecondDomainShowsNonEmptyAttributesTable() throws {
        let app = XCUIApplication()
        app.launch()

        try selectDatabaseTabIfNeeded(in: app)
        waitForDomainsToLoad(in: app)

        let secondDomainRow = app.descendants(matching: .any).matching(identifier: "domainListRow.1").firstMatch
        guard secondDomainRow.waitForExistence(timeout: 5) else {
            throw XCTSkip("Requires at least two SimpleDB domains in the active profile.")
        }

        secondDomainRow.tap()

        let firstDataRow = app.descendants(matching: .any).matching(identifier: "tabularDataRow.0").firstMatch
        XCTAssertTrue(firstDataRow.waitForExistence(timeout: attributesLoadTimeout), "Expected attribute rows after selecting a domain.")
    }

    @MainActor
    func testSelectSecondDomainThenOpenCustomSQL() throws {
        let app = XCUIApplication()
        app.launch()

        try selectDatabaseTabIfNeeded(in: app)
        waitForDomainsToLoad(in: app)

        let secondDomainRow = app.descendants(matching: .any).matching(identifier: "domainListRow.1").firstMatch
        guard secondDomainRow.waitForExistence(timeout: 5) else {
            throw XCTSkip("Requires at least two SimpleDB domains in the active profile.")
        }

        secondDomainRow.tap()

        let firstDataRow = app.descendants(matching: .any).matching(identifier: "tabularDataRow.0").firstMatch
        XCTAssertTrue(firstDataRow.waitForExistence(timeout: attributesLoadTimeout), "Expected attribute rows before using Custom SQL.")

        let customSQLButton = app.buttons["Custom SQL"]
        XCTAssertTrue(customSQLButton.waitForExistence(timeout: 10), "Custom SQL toolbar button should be available when attributes are shown.")
        customSQLButton.tap()

        let customQueryNavBar = app.navigationBars["Custom Query"]
        XCTAssertTrue(customQueryNavBar.waitForExistence(timeout: 10), "Custom Query sheet should appear after tapping Custom SQL.")
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
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
