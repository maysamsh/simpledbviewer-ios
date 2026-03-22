import Foundation
import Testing
@testable import simpledbviewer

struct CustomSQLViewModelTests {
    @Test @MainActor
    func init_seedsQueryWhenDomainProvided() {
        let sut = CustomSQLViewModel(sqlQueryValidator: StubSQLQueryValidator(), domain: "items")

        #expect(sut.state.queryText.contains("items"))
        #expect(sut.state.queryText.contains("select"))
    }

    @Test @MainActor
    func init_emptyDomain_startsWithEmptyQuery() {
        let sut = CustomSQLViewModel(sqlQueryValidator: StubSQLQueryValidator(), domain: nil)

        #expect(sut.state.queryText.isEmpty)
    }

    @Test @MainActor
    func updateQuery_clearsValidationError() {
        let validator = StubSQLQueryValidator()
        validator.sanitizeResult = .failure(SimpleDBQueryError.emptyQuery)
        let sut = CustomSQLViewModel(sqlQueryValidator: validator, domain: nil)
        sut.handle(.updateQuery("x"))
        sut.handle(.submit)
        #expect(sut.state.validationError != nil)

        sut.handle(.updateQuery("y"))

        #expect(sut.state.validationError == nil)
    }

    @Test @MainActor
    func submit_success_setsSubmittedQuery() {
        let validator = StubSQLQueryValidator()
        let sut = CustomSQLViewModel(sqlQueryValidator: validator, domain: nil)
        sut.handle(.updateQuery("select * from `x`"))

        sut.handle(.submit)

        #expect(sut.state.submittedQuery == "sanitized")
        #expect(sut.state.validationError == nil)
    }

    @Test @MainActor
    func submit_failure_setsValidationError() {
        let validator = StubSQLQueryValidator()
        validator.sanitizeResult = .failure(SimpleDBQueryError.emptyQuery)
        let sut = CustomSQLViewModel(sqlQueryValidator: validator, domain: nil)
        sut.handle(.updateQuery("select"))

        sut.handle(.submit)

        #expect(sut.state.submittedQuery == nil)
        #expect(sut.state.validationError != nil)
    }

    @Test @MainActor
    func isSubmitDisabled_whitespaceOnly() {
        let sut = CustomSQLViewModel(sqlQueryValidator: StubSQLQueryValidator(), domain: nil)
        sut.handle(.updateQuery("   \n"))

        #expect(sut.state.isSubmitDisabled == true)
    }

    @Test @MainActor
    func isSubmitDisabled_nonWhitespace() {
        let sut = CustomSQLViewModel(sqlQueryValidator: StubSQLQueryValidator(), domain: nil)
        sut.handle(.updateQuery("select"))

        #expect(sut.state.isSubmitDisabled == false)
    }
}
