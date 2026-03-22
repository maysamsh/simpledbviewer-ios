//
//  AppErrorMapper.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-05.
//

//  Translates raw errors (NSError, AWS SDK) into domain-level AppErrors.
//  All use cases should route through this instead of handling SDK specifics themselves.
//

import Foundation

enum AppErrorMapper {
    static func map(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        let nsError = error as NSError

        if nsError.domain == AWSSimpleDBErrorDomain.domain {
            let codeString = (nsError.userInfo["Code"] as? String) ?? ""
            let message = (nsError.userInfo["Message"] as? String) ?? nsError.localizedDescription
            return mapAWSSimpleDBCode(codeString, message: message)
        }

        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                return .networkUnavailable
            default:
                break
            }
        }

        return .generic(message: error.localizedDescription)
    }

    private static func mapAWSSimpleDBCode(_ code: String, message: String) -> AppError {
        let codeTrimmed = code.trimmingCharacters(in: .whitespaces)
        switch codeTrimmed {
        case AWSSimpleDBErrorDomain.Code.noSuchDomain.rawValue:
            return .noSuchDomain(domainName: "")
        case AWSSimpleDBErrorDomain.Code.authFailure.rawValue:
            return .authFailure
        case AWSSimpleDBErrorDomain.Code.authMissingFailure.rawValue:
            return .authMissingFailure
        case AWSSimpleDBErrorDomain.Code.accessFailure.rawValue:
            return .accessFailure
        case AWSSimpleDBErrorDomain.Code.attributeDoesNotExist.rawValue:
            return .attributeDoesNotExist(attributeName: message)
        case AWSSimpleDBErrorDomain.Code.serviceUnavailable.rawValue:
            return .serviceUnavailable
        case AWSSimpleDBErrorDomain.Code.internalError.rawValue:
            return .internalServiceError
        case AWSSimpleDBErrorDomain.Code.queryTimeout.rawValue:
            return .requestTimeout
        case AWSSimpleDBErrorDomain.Code.accessDeniedException.rawValue,
             AWSSimpleDBErrorDomain.Code.internalFailure.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidClientTokenId.rawValue,
             AWSSimpleDBErrorDomain.Code.notAuthorized.rawValue,
             AWSSimpleDBErrorDomain.Code.optInRequired.rawValue,
             AWSSimpleDBErrorDomain.Code.throttlingException.rawValue,
             AWSSimpleDBErrorDomain.Code.validationError.rawValue,
             AWSSimpleDBErrorDomain.Code.conditionalCheckFailed.rawValue,
             AWSSimpleDBErrorDomain.Code.existsAndExpectedValue.rawValue,
             AWSSimpleDBErrorDomain.Code.featureDeprecated.rawValue,
             AWSSimpleDBErrorDomain.Code.incompleteExpectedExpression.rawValue,
             AWSSimpleDBErrorDomain.Code.incompleteSignature.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidAction.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidHTTPAuthHeader.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidHttpRequest.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidLiteral.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidNextToken.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidNumberPredicates.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidNumberValueTests.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidParameterCombination.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidParameterValue.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidQueryExpression.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidResponseGroups.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidService.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidSortExpression.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidURI.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidWSAddressingProperty.rawValue,
             AWSSimpleDBErrorDomain.Code.invalidWSDLVersion.rawValue,
             AWSSimpleDBErrorDomain.Code.missingAction.rawValue,
             AWSSimpleDBErrorDomain.Code.missingParameter.rawValue,
             AWSSimpleDBErrorDomain.Code.missingWSAddressingProperty.rawValue,
             AWSSimpleDBErrorDomain.Code.multipleExistsConditions.rawValue,
             AWSSimpleDBErrorDomain.Code.multipleExpectedNames.rawValue,
             AWSSimpleDBErrorDomain.Code.multipleExpectedValues.rawValue,
             AWSSimpleDBErrorDomain.Code.multiValuedAttribute.rawValue,
             AWSSimpleDBErrorDomain.Code.noSuchVersion.rawValue,
             AWSSimpleDBErrorDomain.Code.notYetImplemented.rawValue,
             AWSSimpleDBErrorDomain.Code.numberDomainsExceeded.rawValue,
             AWSSimpleDBErrorDomain.Code.numberDomainAttributesExceeded.rawValue,
             AWSSimpleDBErrorDomain.Code.numberDomainBytesExceeded.rawValue,
             AWSSimpleDBErrorDomain.Code.numberItemAttributesExceeded.rawValue,
             AWSSimpleDBErrorDomain.Code.numberSubmittedAttributesExceeded.rawValue,
             AWSSimpleDBErrorDomain.Code.numberSubmittedItemsExceeded.rawValue,
             AWSSimpleDBErrorDomain.Code.requestExpired.rawValue,
             AWSSimpleDBErrorDomain.Code.tooManyRequestedAttributes.rawValue,
             AWSSimpleDBErrorDomain.Code.unsupportedHttpVerb.rawValue,
             AWSSimpleDBErrorDomain.Code.unsupportedNextToken.rawValue,
             AWSSimpleDBErrorDomain.Code.uriTooLong.rawValue:
            return .awsSimpleDB(code: codeTrimmed, message: message)
        default:
            return .awsSimpleDB(code: codeTrimmed.isEmpty ? "Unknown" : codeTrimmed, message: message)
        }
    }
}
