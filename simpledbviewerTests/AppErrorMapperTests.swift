import Foundation
import Testing
@testable import simpledbviewer

struct AppErrorMapperTests {
    @Test
    func map_passthroughAppError() {
        let original = AppError.authFailure
        if case .authFailure = AppErrorMapper.map(original) {
        } else {
            Issue.record("Expected authFailure")
        }
    }

    @Test
    func map_nsURLError_offlineToNetworkUnavailable() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        if case .networkUnavailable = AppErrorMapper.map(error) {
        } else {
            Issue.record("Expected networkUnavailable")
        }
    }

    @Test
    func map_nsURLError_connectionLostToNetworkUnavailable() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost)
        if case .networkUnavailable = AppErrorMapper.map(error) {
        } else {
            Issue.record("Expected networkUnavailable")
        }
    }

    @Test
    func map_nsURLError_otherToGeneric() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL)
        if case .generic = AppErrorMapper.map(error) {
        } else {
            Issue.record("Expected generic AppError")
        }
    }

    @Test
    func map_awsSimpleDB_noSuchDomain() {
        let error = NSError(
            domain: AWSSimpleDBErrorDomain.domain,
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "x", "Code": AWSSimpleDBErrorDomain.Code.noSuchDomain.rawValue])
        if case .noSuchDomain(let name) = AppErrorMapper.map(error) {
            #expect(name.isEmpty)
        } else {
            Issue.record("Expected noSuchDomain")
        }
    }

    @Test
    func map_awsSimpleDB_authFailure() {
        let error = NSError(
            domain: AWSSimpleDBErrorDomain.domain,
            code: 0,
            userInfo: ["Code": AWSSimpleDBErrorDomain.Code.authFailure.rawValue])
        if case .authFailure = AppErrorMapper.map(error) {
        } else {
            Issue.record("Expected authFailure")
        }
    }

    @Test
    func map_awsSimpleDB_attributeDoesNotExistUsesMessage() {
        let error = NSError(
            domain: AWSSimpleDBErrorDomain.domain,
            code: 0,
            userInfo: [
                "Code": AWSSimpleDBErrorDomain.Code.attributeDoesNotExist.rawValue,
                "Message": "attr-1"
            ])
        if case .attributeDoesNotExist(let name) = AppErrorMapper.map(error) {
            #expect(name == "attr-1")
        } else {
            Issue.record("Expected attributeDoesNotExist")
        }
    }

    @Test
    func map_awsSimpleDB_throttlingMapsToAwsSimpleDB() {
        let error = NSError(
            domain: AWSSimpleDBErrorDomain.domain,
            code: 0,
            userInfo: [
                "Code": AWSSimpleDBErrorDomain.Code.throttlingException.rawValue,
                "Message": "Slow down"
            ])
        if case .awsSimpleDB(let code, let message) = AppErrorMapper.map(error) {
            #expect(code == "ThrottlingException")
            #expect(message == "Slow down")
        } else {
            Issue.record("Expected awsSimpleDB")
        }
    }

    @Test
    func map_awsSimpleDB_unknownCodeUsesUnknownLabel() {
        let error = NSError(
            domain: AWSSimpleDBErrorDomain.domain,
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "desc"])
        if case .awsSimpleDB(let code, _) = AppErrorMapper.map(error) {
            #expect(code == "Unknown")
        } else {
            Issue.record("Expected awsSimpleDB")
        }
    }

    @Test
    func map_otherNSErrorToGeneric() {
        let error = NSError(domain: "custom", code: 1, userInfo: [NSLocalizedDescriptionKey: "oops"])
        if case .generic(let message) = AppErrorMapper.map(error) {
            #expect(message == "oops")
        } else {
            Issue.record("Expected generic")
        }
    }
}
