//
//  Persistence.swift
//  Shared
//
//  Created by Kevin Guan on 7/18/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init() {
        container = NSPersistentCloudKitContainer(name: "Privacy_Suite")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save() {
        let context = container.viewContext

        if context.hasChanges {
            print("hasChanges")
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func isAvailable() -> Bool {
        let count = try? container.viewContext.count(for: NSFetchRequest(entityName: "ConfigItem"))
        return count == 1
    }

    func savePassword(password: String) {
        if let encrypted = EncryptionHelper.encryptString(input: "password", withPassword: password) {
            container.viewContext.performAndWait {
                let config = ConfigItem(context: container.viewContext)
                config.password = encrypted
                save()
            }
        }
    }

    func checkPassword(password: String) -> Bool {
        let results = try? container.viewContext.fetch(NSFetchRequest(entityName: "ConfigItem")) as? [ConfigItem]
        if let result = results?.first?.password {
            if EncryptionHelper.decryptString(encrypted: result, withPassword: password) == "password" {
                return true
            }
        }
        return false
    }
}
