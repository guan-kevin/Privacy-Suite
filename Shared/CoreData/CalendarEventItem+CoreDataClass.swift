//
//  CalendarEventItem+CoreDataClass.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/29/21.
//
//

import Foundation
import CoreData

@objc(CalendarEventItem)
public class CalendarEventItem: NSManagedObject {
    var decryptedTitle: String?
    var decryptedStart: Date?
    var decryptedEnd: Date?

    var encryptedTitle: String?
    var encryptedStart: String?
    var encryptedEnd: String?
}
