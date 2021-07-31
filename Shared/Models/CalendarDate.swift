//
//  CalendarDate.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/31/21.
//

import Foundation

struct CalendarDate: Identifiable, Codable {
    var id = UUID()

    var date: Date
    var currentMonth: Bool
}
