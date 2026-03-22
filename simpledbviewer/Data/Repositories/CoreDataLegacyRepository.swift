//
//  CoreDataLegacyRepository.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-10.
//


import CoreData
import Foundation

final class CoreDataLegacyRepository: LegacyStorageRepository {
    private let storeURL: URL
    private var cachedContext: NSManagedObjectContext?

    init(storeURL: URL = CoreDataLegacyRepository.defaultStoreURL()) {
        self.storeURL = storeURL
    }

    func fetchLegacyCredential() throws -> AWSCredentialEntity? {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return nil }
        let request = NSFetchRequest<NSManagedObject>(entityName: "AWSAccessInfo")
        request.fetchLimit = 1
        let results = try context().fetch(request)
        return results.first.map(mapToEntity)
    }

    func deleteLegacyData() throws {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return }
        let context = try context()
        let request = NSFetchRequest<NSManagedObject>(entityName: "AWSAccessInfo")
        let results = try context.fetch(request)
        results.forEach { context.delete($0) }
        try context.save()
    }

    private func context() throws -> NSManagedObjectContext {
        if let context = cachedContext { return context }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: makeModel())
        let options: [String: Any] = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        do {
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: options)
        } catch {
            throw AppError.generic(message: "Failed to open legacy store: \(error.localizedDescription)")
        }
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        cachedContext = context
        return context
    }

    private func mapToEntity(_ object: NSManagedObject) -> AWSCredentialEntity {
        let region = object.value(forKey: "region") as? String ?? ""
        return AWSCredentialEntity(
            id: UUID().uuidString,
            displayName: region.isEmpty ? "Default" : region,
            region: region,
            accessKey: object.value(forKey: "key") as? String ?? "",
            secretKey: object.value(forKey: "secret") as? String ?? "")
    }

    private func makeModel() -> NSManagedObjectModel {
        let entity = NSEntityDescription()
        entity.name = "AWSAccessInfo"
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        entity.properties = [("id", ""), ("key", ""), ("secret", ""), ("region", "")].map { name, _ in
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

    private static func defaultStoreURL() -> URL {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("simpledbviewer.sqlite")
    }
}
