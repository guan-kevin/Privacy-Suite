//
//  Note.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/21/21.
//

import Foundation

struct Note: Identifiable, Codable {
    var id = UUID()

    var title: String
    var content: String
    var dateCreated: Date
    var lastEdited: Date
}
