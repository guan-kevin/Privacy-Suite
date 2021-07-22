//
//  NoteItem+CoreDataClass.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/21/21.
//
//

import CoreData
import Foundation

@objc(NoteItem)
public class NoteItem: NSManagedObject {
    var decryptedTitle: String?
    var decryptedContent: String?

    var encryptedTitle: String?
    var encryptedContent: String?
}
