// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Source: Localizable.xcstrings
  internal static func column(_ p1: Any) -> String {
    return L10n.tr("Localizable", "%@ column", String(describing: p1), fallback: "%@ column")
  }
  /// Access Key
  internal static let accessKey = L10n.tr("Localizable", "Access Key", fallback: "Access Key")
  /// Acknowledgments
  internal static let acknowledgments = L10n.tr("Localizable", "Acknowledgments", fallback: "Acknowledgments")
  /// Add a profile
  internal static let addAProfile = L10n.tr("Localizable", "Add a profile", fallback: "Add a profile")
  /// Add Profile
  internal static let addProfile = L10n.tr("Localizable", "Add Profile", fallback: "Add Profile")
  /// Allowed range: 0 to 2500
  internal static let allowedRange0To2500 = L10n.tr("Localizable", "Allowed range: 0 to 2500", fallback: "Allowed range: 0 to 2500")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "Cancel", fallback: "Cancel")
  /// Closes the custom query screen
  internal static let closesTheCustomQueryScreen = L10n.tr("Localizable", "Closes the custom query screen", fallback: "Closes the custom query screen")
  /// Closes the share sheet
  internal static let closesTheShareSheet = L10n.tr("Localizable", "Closes the share sheet", fallback: "Closes the share sheet")
  /// Copies the error description to the clipboard
  internal static let copiesTheErrorDescriptionToTheClipboard = L10n.tr("Localizable", "Copies the error description to the clipboard", fallback: "Copies the error description to the clipboard")
  /// Copy error
  internal static let copyError = L10n.tr("Localizable", "Copy error", fallback: "Copy error")
  /// Copy error description
  internal static let copyErrorDescription = L10n.tr("Localizable", "Copy error description", fallback: "Copy error description")
  /// Custom Query
  internal static let customQuery = L10n.tr("Localizable", "Custom Query", fallback: "Custom Query")
  /// Custom SQL
  internal static let customSQL = L10n.tr("Localizable", "Custom SQL", fallback: "Custom SQL")
  /// -
  internal static let dash = L10n.tr("Localizable", "dash", fallback: "-")
  /// Database
  internal static let database = L10n.tr("Localizable", "Database", fallback: "Database")
  /// Default query limit
  internal static let defaultQueryLimit = L10n.tr("Localizable", "Default query limit", fallback: "Default query limit")
  /// Delete
  internal static let delete = L10n.tr("Localizable", "Delete", fallback: "Delete")
  /// Delete %@
  internal static func delete(_ p1: Any) -> String {
    return L10n.tr("Localizable", "Delete %@", String(describing: p1), fallback: "Delete %@")
  }
  /// Delete Profile
  internal static let deleteProfile = L10n.tr("Localizable", "Delete Profile", fallback: "Delete Profile")
  /// Domains
  internal static let domains = L10n.tr("Localizable", "Domains", fallback: "Domains")
  /// Done
  internal static let done = L10n.tr("Localizable", "Done", fallback: "Done")
  /// Enter a custom SQL query
  internal static let enterACustomSQLQuery = L10n.tr("Localizable", "Enter a custom SQL query", fallback: "Enter a custom SQL query")
  /// Error: %@
  internal static func error(_ p1: Any) -> String {
    return L10n.tr("Localizable", "Error: %@", String(describing: p1), fallback: "Error: %@")
  }
  /// Exports and opens the sharing screen for report file
  internal static let exportsAndOpensTheSharingScreenForReportFile = L10n.tr("Localizable", "Exports and opens the sharing screen for report file", fallback: "Exports and opens the sharing screen for report file")
  /// Go to setup
  internal static let goToSetup = L10n.tr("Localizable", "Go to setup", fallback: "Go to setup")
  /// Invalid SQL query
  internal static let invalidSQLQuery = L10n.tr("Localizable", "Invalid SQL query", fallback: "Invalid SQL query")
  /// Item %@
  internal static func item(_ p1: Any) -> String {
    return L10n.tr("Localizable", "Item %@", String(describing: p1), fallback: "Item %@")
  }
  /// Item Name
  internal static let itemName = L10n.tr("Localizable", "Item Name", fallback: "Item Name")
  /// Limit must be between %lld and %lld.
  internal static func limitMustBeBetweenLldAndLld(_ p1: Int, _ p2: Int) -> String {
    return L10n.tr("Localizable", "Limit must be between %lld and %lld.", p1, p2, fallback: "Limit must be between %lld and %lld.")
  }
  /// Loading
  internal static let loading = L10n.tr("Localizable", "Loading", fallback: "Loading")
  /// Loading domains
  internal static let loadingDomains = L10n.tr("Localizable", "Loading domains", fallback: "Loading domains")
  /// Loading profiles
  internal static let loadingProfiles = L10n.tr("Localizable", "Loading profiles", fallback: "Loading profiles")
  /// Loading stored profiles
  internal static let loadingStoredProfiles = L10n.tr("Localizable", "Loading stored profiles", fallback: "Loading stored profiles")
  /// No Domains
  internal static let noDomains = L10n.tr("Localizable", "No Domains", fallback: "No Domains")
  /// No Profile Added
  internal static let noProfileAdded = L10n.tr("Localizable", "No Profile Added", fallback: "No Profile Added")
  /// No Profiles
  internal static let noProfiles = L10n.tr("Localizable", "No Profiles", fallback: "No Profiles")
  /// No profiles stored.
  internal static let noProfilesStored = L10n.tr("Localizable", "No profiles stored.", fallback: "No profiles stored.")
  /// Opens attributes for %@
  internal static func opensAttributesFor(_ p1: Any) -> String {
    return L10n.tr("Localizable", "Opens attributes for %@", String(describing: p1), fallback: "Opens attributes for %@")
  }
  /// Opens the list of stored profiles
  internal static let opensTheListOfStoredProfiles = L10n.tr("Localizable", "Opens the list of stored profiles", fallback: "Opens the list of stored profiles")
  /// Opens the screen to add a new profile
  internal static let opensTheScreenToAddANewProfile = L10n.tr("Localizable", "Opens the screen to add a new profile", fallback: "Opens the screen to add a new profile")
  /// Opens the screen to run a custom query
  internal static let opensTheScreenToRunACustomQuery = L10n.tr("Localizable", "Opens the screen to run a custom query", fallback: "Opens the screen to run a custom query")
  /// Opens the system share sheet for report
  internal static let opensTheSystemShareSheetForReport = L10n.tr("Localizable", "Opens the system share sheet for report", fallback: "Opens the system share sheet for report")
  /// Profile Name
  internal static let profileName = L10n.tr("Localizable", "Profile Name", fallback: "Profile Name")
  /// Profiles
  internal static let profiles = L10n.tr("Localizable", "Profiles", fallback: "Profiles")
  /// Query Builder
  internal static let queryBuilder = L10n.tr("Localizable", "Query Builder", fallback: "Query Builder")
  /// Region
  internal static let region = L10n.tr("Localizable", "Region", fallback: "Region")
  /// Run Query
  internal static let runQuery = L10n.tr("Localizable", "Run Query", fallback: "Run Query")
  /// Runs the custom query
  internal static let runsTheCustomQuery = L10n.tr("Localizable", "Runs the custom query", fallback: "Runs the custom query")
  /// Save
  internal static let save = L10n.tr("Localizable", "Save", fallback: "Save")
  /// Save Profile
  internal static let saveProfile = L10n.tr("Localizable", "Save Profile", fallback: "Save Profile")
  /// Saves the AWS credentials for this profile
  internal static let savesTheAWSCredentialsForThisProfile = L10n.tr("Localizable", "Saves the AWS credentials for this profile", fallback: "Saves the AWS credentials for this profile")
  /// Secret access key
  internal static let secretAccessKey = L10n.tr("Localizable", "Secret access key", fallback: "Secret access key")
  /// Select a domain
  internal static let selectADomain = L10n.tr("Localizable", "Select a domain", fallback: "Select a domain")
  /// Select a profile
  internal static let selectAProfile = L10n.tr("Localizable", "Select a profile", fallback: "Select a profile")
  /// Select profile %@
  internal static func selectProfile(_ p1: Any) -> String {
    return L10n.tr("Localizable", "Select profile %@", String(describing: p1), fallback: "Select profile %@")
  }
  /// Select the AWS region
  internal static let selectTheAWSRegion = L10n.tr("Localizable", "Select the AWS region", fallback: "Select the AWS region")
  /// Selects this profile and closes the list
  internal static let selectsThisProfileAndClosesTheList = L10n.tr("Localizable", "Selects this profile and closes the list", fallback: "Selects this profile and closes the list")
  /// Settings
  internal static let settings = L10n.tr("Localizable", "Settings", fallback: "Settings")
  /// Share %@
  internal static func share(_ p1: Any) -> String {
    return L10n.tr("Localizable", "Share %@", String(describing: p1), fallback: "Share %@")
  }
  /// Share CSV
  internal static let shareCSV = L10n.tr("Localizable", "Share CSV", fallback: "Share CSV")
  /// Share CSV report
  internal static let shareCSVReport = L10n.tr("Localizable", "Share CSV report", fallback: "Share CSV report")
  /// Something went wrong.
  internal static let somethingWentWrong = L10n.tr("Localizable", "Something went wrong.", fallback: "Something went wrong.")
  /// Source Code
  internal static let sourceCode = L10n.tr("Localizable", "Source Code", fallback: "Source Code")
  /// SQL query
  internal static let sqlQuery = L10n.tr("Localizable", "SQL query", fallback: "SQL query")
  /// Stored profile %@
  internal static func storedProfile(_ p1: Any) -> String {
    return L10n.tr("Localizable", "Stored profile %@", String(describing: p1), fallback: "Stored profile %@")
  }
  /// Stored Profiles
  internal static let storedProfiles = L10n.tr("Localizable", "Stored Profiles", fallback: "Stored Profiles")
  /// Tap + to add your AWS credentials and get started.
  internal static let tapToAddYourAWSCredentialsAndGetStarted = L10n.tr("Localizable", "Tap + to add your AWS credentials and get started.", fallback: "Tap + to add your AWS credentials and get started.")
  /// This account does not have any domains yet.
  internal static let thisAccountDoesNotHaveAnyDomainsYet = L10n.tr("Localizable", "This account does not have any domains yet.", fallback: "This account does not have any domains yet.")
  /// This app uses the AWS SDK for Swift.
  internal static let thisAppUsesTheAWSSDKForSwift = L10n.tr("Localizable", "This app uses the AWS SDK for Swift.", fallback: "This app uses the AWS SDK for Swift.")
  /// With love from Toronto
  internal static let withLoveFromToronto = L10n.tr("Localizable", "With love from Toronto", fallback: "With love from Toronto")
  /// You have not added any profiles yet.
  internal static let youHaveNotAddedAnyProfilesYet = L10n.tr("Localizable", "You have not added any profiles yet.", fallback: "You have not added any profiles yet.")
  /// You need to add your AWS secret and key first
  internal static let youNeedToAddYourAWSSecretAndKeyFirst = L10n.tr("Localizable", "You need to add your AWS secret and key first", fallback: "You need to add your AWS secret and key first")
  internal enum IsReadyToShare {
    /// %@ is ready to share. It contains %lld records and is %@.
    internal static func itContainsLldRecordsAndIs(_ p1: Any, _ p2: Int, _ p3: Any) -> String {
      return L10n.tr("Localizable", "%@ is ready to share. It contains %lld records and is %@.", String(describing: p1), p2, String(describing: p3), fallback: "%@ is ready to share. It contains %lld records and is %@.")
    }
    /// %@ is ready to share. It contains %lld records.
    internal static func itContainsLldRecords(_ p1: Any, _ p2: Int) -> String {
      return L10n.tr("Localizable", "%@ is ready to share. It contains %lld records.", String(describing: p1), p2, fallback: "%@ is ready to share. It contains %lld records.")
    }
  }
  internal enum LicensedUnderTheApacheLicenseVersion2 {
    /// Licensed under the Apache License, Version 2.0.
    internal static let _0 = L10n.tr("Localizable", "Licensed under the Apache License, Version 2.0.", fallback: "Licensed under the Apache License, Version 2.0.")
  }
  internal enum SourceCodeAndProjectHistoryAreOnGitHub {
    /// Source code and project history are on GitHub. License terms are in the repository.
    internal static let licenseTermsAreInTheRepository = L10n.tr("Localizable", "Source code and project history are on GitHub. License terms are in the repository.", fallback: "Source code and project history are on GitHub. License terms are in the repository.")
  }
  internal enum UnknownRegion {
    /// Unknown region '%@'. Please re-add the profile.
    internal static func pleaseReAddTheProfile(_ p1: Any) -> String {
      return L10n.tr("Localizable", "Unknown region '%@'. Please re-add the profile.", String(describing: p1), fallback: "Unknown region '%@'. Please re-add the profile.")
    }
  }
  internal enum Accessibility {
    /// No profiles
    internal static let noProfiles = L10n.tr("Localizable", "accessibility.no_profiles", fallback: "No profiles")
    /// No profiles stored
    internal static let noProfilesStored = L10n.tr("Localizable", "accessibility.no_profiles_stored", fallback: "No profiles stored")
  }
  internal enum Alert {
    /// Are you sure you want to delete "%@"? This action cannot be undone.
    internal static func deleteProfileConfirmation(_ p1: Any) -> String {
      return L10n.tr("Localizable", "alert.delete_profile_confirmation", String(describing: p1), fallback: "Are you sure you want to delete \"%@\"? This action cannot be undone.")
    }
  }
  internal enum Format {
    /// %1$@ %2$@
    internal static func accessibilityColumnValue(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "format.accessibility_column_value", String(describing: p1), String(describing: p2), fallback: "%1$@ %2$@")
    }
  }
  internal enum Github {
    /// github.com/awslabs/aws-sdk-swift
    internal static let comAwslabsAwsSdkSwift = L10n.tr("Localizable", "github.com/awslabs/aws-sdk-swift", fallback: "github.com/awslabs/aws-sdk-swift")
    /// github.com/maysamsh/simpledbviewer-ios
    internal static let comMaysamshSimpledbviewerIos = L10n.tr("Localizable", "github.com/maysamsh/simpledbviewer-ios", fallback: "github.com/maysamsh/simpledbviewer-ios")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
