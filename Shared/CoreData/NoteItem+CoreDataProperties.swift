//
//  NoteItem+CoreDataProperties.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/21/21.
//
//

import CoreData
import Foundation

public extension NoteItem {
    @nonobjc class func fetchRequest() -> NSFetchRequest<NoteItem> {
        return NSFetchRequest<NoteItem>(entityName: "NoteItem")
    }

    @NSManaged var title: String?
    @NSManaged var content: String?
    @NSManaged var dateCreated: Date?
    @NSManaged var lastEdited: Date?
}

extension NoteItem: Identifiable {
    static var getFetchRequest: NSFetchRequest<NoteItem> {
        let request: NSFetchRequest<NoteItem> = NoteItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \NoteItem.lastEdited, ascending: false)]

        return request
    }

    func getTitle() -> String {
        if decryptedTitle == nil || encryptedTitle != title {
            encryptedTitle = title
            decryptedTitle = EncryptionHelper.decryptString(encrypted: title, withPassword: ValetController.getPassword().0)
        }

        return decryptedTitle ?? "Untitled"
    }

    func getContent() -> String {
        if decryptedContent == nil || encryptedContent != content {
            encryptedContent = content

            decryptedContent = EncryptionHelper.decryptString(encrypted: content, withPassword: ValetController.getPassword().0)
        }

        return decryptedContent ?? "Untitled"
    }
}
