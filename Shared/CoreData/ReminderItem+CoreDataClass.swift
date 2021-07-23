//
//  ReminderItem+CoreDataClass.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/22/21.
//
//

import Foundation
import CoreData

@objc(ReminderItem)
public class ReminderItem: NSManagedObject {
    var decryptedTitle: String?
    var decryptedNotes: String?

    var encryptedTitle: String?
    var encryptedNotes: String?
}
