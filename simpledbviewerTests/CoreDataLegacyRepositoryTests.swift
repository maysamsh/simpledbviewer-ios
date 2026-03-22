import CoreData
import Foundation
import Testing
@testable import simpledbviewer

struct CoreDataLegacyRepositoryTests {
    @Test
    func fetchLegacy_missingStoreReturnsNil() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("legacy-missing-\(UUID().uuidString).sqlite")
        let sut = CoreDataLegacyRepository(storeURL: url)

        let cred = try sut.fetchLegacyCredential()

        #expect(cred == nil)
    }

    @Test
    func fetchLegacy_mapsStoredRow() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("legacy-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent("legacy.sqlite")
        defer { try? FileManager.default.removeItem(at: dir) }

        try seedLegacyStore(at: url, key: "access", secret: "secret", region: "us-east-1")

        let sut = CoreDataLegacyRepository(storeURL: url)
        let cred = try sut.fetchLegacyCredential()

        #expect(cred?.accessKey == "access")
        #expect(cred?.secretKey == "secret")
        #expect(cred?.region == "us-east-1")
        #expect(cred?.displayName == "us-east-1")
    }

    @Test
    func deleteLegacy_clearsStoredCredential() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("legacy-delete-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent("legacy.sqlite")
        defer { try? FileManager.default.removeItem(at: dir) }

        try seedLegacyStore(at: url, key: "k", secret: "s", region: "us-west-1")
        let sut = CoreDataLegacyRepository(storeURL: url)
        #expect(try sut.fetchLegacyCredential() != nil)

        try sut.deleteLegacyData()

        #expect(try sut.fetchLegacyCredential() == nil)
    }
}

private func seedLegacyStore(at storeURL: URL, key: String, secret: String, region: String) throws {
    let model = legacyTestModel()
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    try coordinator.addPersistentStore(
        ofType: NSSQLiteStoreType,
        configurationName: nil,
        at: storeURL,
        options: nil)
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = coordinator
    guard let entity = model.entitiesByName["AWSAccessInfo"] else {
        throw NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing entity"])
    }
    let object = NSManagedObject(entity: entity, insertInto: context)
    object.setValue("legacy-id", forKey: "id")
    object.setValue(key, forKey: "key")
    object.setValue(secret, forKey: "secret")
    object.setValue(region, forKey: "region")
    try context.save()
}

private func legacyTestModel() -> NSManagedObjectModel {
    let entity = NSEntityDescription()
    entity.name = "AWSAccessInfo"
    entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
    entity.properties = ["id", "key", "secret", "region"].map { name in
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = true
        return attribute
    }
    let model = NSManagedObjectModel()
    model.entities = [entity]
    return model
}
