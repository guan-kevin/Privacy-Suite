//
//  ReminderItem+CoreDataProperties.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/22/21.
//
//

import CoreData
import Foundation

public extension ReminderItem {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ReminderItem> {
        return NSFetchRequest<ReminderItem>(entityName: "ReminderItem")
    }

    @NSManaged var title: String?
    @NSManaged var notes: String?
    @NSManaged var dateCreated: Date?
    @NSManaged var date: Date?
    @NSManaged var priority: Int16
    @NSManaged var completed: NSNumber
    var isCompleted: Bool {
        get {
            return Bool(truncating: completed)
        }
        set {
            completed = NSNumber(value: newValue)
        }
    }

    @NSManaged var list: ReminderListItem?
}

extension ReminderItem: Identifiable {
    func getTitle() -> String {
        if decryptedTitle == nil || encryptedTitle != title {
            encryptedTitle = title
            decryptedTitle = EncryptionHelper.decryptString(encrypted: title, withPassword: ValetController.getPassword().0)
        }

        return decryptedTitle ?? "Untitled"
    }

    func getNotes() -> String {
        if decryptedNotes == nil || decryptedNotes != notes {
            encryptedNotes = notes
            decryptedNotes = EncryptionHelper.decryptString(encrypted: notes, withPassword: ValetController.getPassword().0)
        }

        return encryptedNotes ?? "Untitled"
    }
}
