//
//  ReminderListItem+CoreDataProperties.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/22/21.
//
//

import CoreData
import Foundation

public extension ReminderListItem {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ReminderListItem> {
        return NSFetchRequest<ReminderListItem>(entityName: "ReminderListItem")
    }

    @NSManaged var name: String?
    @NSManaged var reminders: NSSet?

    var reminderArray: [ReminderItem] {
        let set = reminders as? Set<ReminderItem> ?? []
        return set.sorted {
            // both (not) completed
            if $0.isCompleted == $1.isCompleted {
                if $0.priority != $1.priority {
                    // priority first
                    return $0.priority > $1.priority
                } else {
                    // date created next
                    return $0.dateCreated ?? Date() < $1.dateCreated ?? Date()
                }
            } else {
                // not completed one first
                return !$0.isCompleted
            }
        }
    }

    var todoReminderArray: [ReminderItem] {
        reminderArray.filter { !$0.isCompleted }
    }

    var listName: String {
        return name ?? "Untitled"
    }
}

// MARK: Generated accessors for reminders

public extension ReminderListItem {
    @objc(addRemindersObject:)
    @NSManaged func addToReminders(_ value: ReminderItem)

    @objc(removeRemindersObject:)
    @NSManaged func removeFromReminders(_ value: ReminderItem)

    @objc(addReminders:)
    @NSManaged func addToReminders(_ values: NSSet)

    @objc(removeReminders:)
    @NSManaged func removeFromReminders(_ values: NSSet)
}

extension ReminderListItem: Identifiable {
    static var getFetchRequest: NSFetchRequest<ReminderListItem> {
        let request: NSFetchRequest<ReminderListItem> = ReminderListItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ReminderListItem.name, ascending: true)]

        return request
    }
}
