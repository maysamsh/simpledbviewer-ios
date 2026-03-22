import Foundation
import Testing
@testable import simpledbviewer

struct UserDefaultsRepositoryTests {
    @Test
    func write_read_stringValues() {
        let suiteName = "simpledbviewer.UserDefaultsRepositoryTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            Issue.record("Could not create UserDefaults suite")
            return
        }
        defer {
            for key in defaults.dictionaryRepresentation().keys {
                defaults.removeObject(forKey: key)
            }
        }

        let sut = UserDefaultsRepository(userDefaults: defaults)

        sut.setValue(key: .migrationToV2, value: "done")
        sut.setValue(key: .latestAddedId, value: "profile-1")

        #expect(sut.getValue(for: .migrationToV2) == "done")
        #expect(sut.getValue(for: .latestAddedId) == "profile-1")
        #expect(sut.getValue(for: .queryDefaultLimit) == nil)
    }
}
