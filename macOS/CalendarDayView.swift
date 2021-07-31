//
//  CalendarDayView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/31/21.
//

import SwiftUI

struct CalendarDayView: View {
    let day: CalendarDate

    var body: some View {
        let number = Calendar.current.component(.day, from: day.date)
        Text("\(number == 1 ? day.date.month + " " : "")\(number)")
            .font(.system(.title2, design: .rounded))
            .foregroundColor(day.currentMonth ? .white : .gray)
    }
}
