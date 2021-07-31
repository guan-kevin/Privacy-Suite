//
//  Date+Extension.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/31/21.
//

import Foundation

extension Date {
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self)
    }

    var fullMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }

    func startOfMonth() -> (date: Date, weekday: Int) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)

        let date = calendar.date(from: components)! // start of month

        let weekday = calendar.component(.weekday, from: date) // weekday
        return (date, weekday)
    }

    func daysPerMonth() -> Int {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.range(of: .day, in: .month, for: startOfMonth().date)?.count ?? 0
    }
}
