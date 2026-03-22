//
//  AppError.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-05.
//

//  Domain-level errors: what the app can show/handle. UI and Data stay decoupled.
//  AWS SimpleDB: https://docs.aws.amazon.com/AmazonSimpleDB/latest/DeveloperGuide/APIError.html
//  Common AWS errors: https://docs.aws.amazon.com/STS/latest/APIReference/CommonErrors.html
//

import Foundation

/// User-facing errors used across the app. Map repository/SDK errors to these in use cases.
enum AppError: Error, LocalizedError {
    case noCredentials
    case notConnected
    case unauthorized
    case networkUnavailable
    case invalidConfiguration
    case notFound(what: String)
    case generic(message: String)

    // MARK: - AWS SimpleDB (mapped from API error codes)

    /// The specified domain does not exist. (NoSuchDomain)
    case noSuchDomain(domainName: String)
    /// AWS was not able to validate the provided access keys. (AuthFailure)
    case authFailure
    /// Access keys are missing. (AuthMissingFailure)
    case authMissingFailure
    /// Access to the resource is denied. (AccessFailure)
    case accessFailure
    /// Attribute does not exist. (AttributeDoesNotExist)
    case attributeDoesNotExist(attributeName: String)
    /// Service busy / too many requests; retry with backoff. (ServiceUnavailable, 503)
    case serviceUnavailable
    /// Internal service error. (InternalError, 500)
    case internalServiceError
    /// Request timeout. (QueryTimeout, 408)
    case requestTimeout
    /// Any other AWS SimpleDB error; code and message preserved.
    case awsSimpleDB(code: String, message: String)

    var errorDescription: String? {
        switch self {
        case .noCredentials:
            return "No profile added yet. Tap + to add your AWS credentials."
        case .notConnected:
            return "No database connection. Add credentials to connect."
        case .unauthorized:
            return "Invalid credentials. Check access key and secret."
        case .networkUnavailable:
            return "Network unavailable. Check your connection."
        case .invalidConfiguration:
            return "Invalid configuration. Please check settings."
        case .notFound(let what):
            return "Not found: \(what)."
        case .generic(let message):
            return message
        case .noSuchDomain(let domainName):
            if domainName.isEmpty { return "The specified domain does not exist." }
            return "The specified domain does not exist: \(domainName)."
        case .authFailure:
            return "AWS was not able to validate the provided access keys."
        case .authMissingFailure:
            return "Access keys are missing. Please add credentials."
        case .accessFailure:
            return "Access to the resource is denied."
        case .attributeDoesNotExist(let attributeName):
            return "Attribute does not exist: \(attributeName)."
        case .serviceUnavailable:
            return "SimpleDB is busy. Try again in a moment or reduce request frequency."
        case .internalServiceError:
            return "A temporary error occurred. Please try again."
        case .requestTimeout:
            return "The request timed out. Please try again."
        case .awsSimpleDB(let code, let message):
            return message.isEmpty ? "AWS SimpleDB error: \(code)." : message
        }
    }
}

// MARK: - AWS SimpleDB error domain and codes

/// Domain for NSErrors from the AWS SimpleDB SDK.
/// SimpleDB codes: https://docs.aws.amazon.com/AmazonSimpleDB/latest/DeveloperGuide/APIError.html
/// Common AWS codes: https://docs.aws.amazon.com/STS/latest/APIReference/CommonErrors.html
enum AWSSimpleDBErrorDomain {
    static let domain = "com.amazonaws.AWSSimpleDBErrorDomain"

    /// All Amazon SimpleDB API error code strings + common AWS error codes (UserInfo["Code"]).
    enum Code: String, CaseIterable {
        // MARK: - Common AWS errors (all services)
        case accessDeniedException = "AccessDeniedException"
        case internalFailure = "InternalFailure"
        case invalidClientTokenId = "InvalidClientTokenId"
        case notAuthorized = "NotAuthorized"
        case optInRequired = "OptInRequired"
        case throttlingException = "ThrottlingException"
        case validationError = "ValidationError"
        // MARK: - SimpleDB API errors
        case accessFailure = "AccessFailure"
        case attributeDoesNotExist = "AttributeDoesNotExist"
        case authFailure = "AuthFailure"
        case authMissingFailure = "AuthMissingFailure"
        case conditionalCheckFailed = "ConditionalCheckFailed"
        case existsAndExpectedValue = "ExistsAndExpectedValue"
        case featureDeprecated = "FeatureDeprecated"
        case incompleteExpectedExpression = "IncompleteExpectedExpression"
        case incompleteSignature = "IncompleteSignature"
        case internalError = "InternalError"
        case invalidAction = "InvalidAction"
        case invalidHTTPAuthHeader = "InvalidHTTPAuthHeader"
        case invalidHttpRequest = "InvalidHttpRequest"
        case invalidLiteral = "InvalidLiteral"
        case invalidNextToken = "InvalidNextToken"
        case invalidNumberPredicates = "InvalidNumberPredicates"
        case invalidNumberValueTests = "InvalidNumberValueTests"
        case invalidParameterCombination = "InvalidParameterCombination"
        case invalidParameterValue = "InvalidParameterValue"
        case invalidQueryExpression = "InvalidQueryExpression"
        case invalidResponseGroups = "InvalidResponseGroups"
        case invalidService = "InvalidService"
        case invalidSortExpression = "InvalidSortExpression"
        case invalidURI = "InvalidURI"
        case invalidWSAddressingProperty = "InvalidWSAddressingProperty"
        case invalidWSDLVersion = "InvalidWSDLVersion"
        case missingAction = "MissingAction"
        case missingParameter = "MissingParameter"
        case missingWSAddressingProperty = "MissingWSAddressingProperty"
        case multipleExistsConditions = "MultipleExistsConditions"
        case multipleExpectedNames = "MultipleExpectedNames"
        case multipleExpectedValues = "MultipleExpectedValues"
        case multiValuedAttribute = "MultiValuedAttribute"
        case noSuchDomain = "NoSuchDomain"
        case noSuchVersion = "NoSuchVersion"
        case notYetImplemented = "NotYetImplemented"
        case numberDomainsExceeded = "NumberDomainsExceeded"
        case numberDomainAttributesExceeded = "NumberDomainAttributesExceeded"
        case numberDomainBytesExceeded = "NumberDomainBytesExceeded"
        case numberItemAttributesExceeded = "NumberItemAttributesExceeded"
        case numberSubmittedAttributesExceeded = "NumberSubmittedAttributesExceeded"
        case numberSubmittedItemsExceeded = "NumberSubmittedItemsExceeded"
        case requestExpired = "RequestExpired"
        case queryTimeout = "QueryTimeout"
        case serviceUnavailable = "ServiceUnavailable"
        case tooManyRequestedAttributes = "TooManyRequestedAttributes"
        case unsupportedHttpVerb = "UnsupportedHttpVerb"
        case unsupportedNextToken = "UnsupportedNextToken"
        case uriTooLong = "URITooLong"
    }
}
