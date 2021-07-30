//
//  CalendarEventItem+CoreDataProperties.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/29/21.
//
//

import CoreData
import Foundation

public extension CalendarEventItem {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CalendarEventItem> {
        return NSFetchRequest<CalendarEventItem>(entityName: "CalendarEventItem")
    }

    @NSManaged var title: String?
    @NSManaged var start: String?
    @NSManaged var end: String?
    @NSManaged var list: CalendarListItem?
}

extension CalendarEventItem: Identifiable {
    func getTitle() -> String {
        if decryptedTitle == nil || encryptedTitle != title {
            encryptedTitle = title
            decryptedTitle = EncryptionHelper.decryptString(encrypted: title, withPassword: ValetController.getPassword().0)
        }

        return decryptedTitle ?? "Untitled"
    }

    func getStart() -> Date {
        if decryptedStart == nil || encryptedStart != start {
            encryptedStart = start
            if let result = EncryptionHelper.decryptString(encrypted: start, withPassword: ValetController.getPassword().0), let time = Double(result) {
                decryptedStart = Date(timeIntervalSince1970: time)
            }
        }

        return decryptedStart ?? Date()
    }
    
    func getEnd() -> Date {
        if decryptedEnd == nil || encryptedEnd != end {
            encryptedEnd = end
            if let result = EncryptionHelper.decryptString(encrypted: end, withPassword: ValetController.getPassword().0), let time = Double(result) {
                decryptedEnd = Date(timeIntervalSince1970: time)
            }
        }

        return decryptedEnd ?? Date()
    }
}
