//
//  CalendarListItem+CoreDataProperties.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/29/21.
//
//

import CoreData
import Foundation

public extension CalendarListItem {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CalendarListItem> {
        return NSFetchRequest<CalendarListItem>(entityName: "CalendarListItem")
    }

    @NSManaged var name: String?
    @NSManaged var color: String?
    @NSManaged var events: NSSet?

    internal var listName: String {
        return name ?? "Untitled"
    }
}

// MARK: Generated accessors for events

public extension CalendarListItem {
    @objc(addEventsObject:)
    @NSManaged func addToEvents(_ value: CalendarEventItem)

    @objc(removeEventsObject:)
    @NSManaged func removeFromEvents(_ value: CalendarEventItem)

    @objc(addEvents:)
    @NSManaged func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged func removeFromEvents(_ values: NSSet)
}

extension CalendarListItem: Identifiable {
    static var getFetchRequest: NSFetchRequest<CalendarListItem> {
        let request: NSFetchRequest<CalendarListItem> = CalendarListItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CalendarListItem.name, ascending: true)]

        return request
    }
}
