//
//  CalendarDayView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/31/21.
//

import SwiftUI

struct CalendarDayView: View {
    let day: CalendarDate
    let currentDate: String

    @State var showNewEventPopup = false

    var body: some View {
        HStack {
            Spacer()
            VStack {
                let display = Calendar.current.dateComponents([.year, .month, .day], from: day.date)

                if currentDate == "\(display.year!):\(display.month!)\(display.day!)" {
                    Text("\(display.day == 1 ? day.date.month + " " : "")\(display.day!)")
                        .font(.system(.title2, design: .rounded))
                        .foregroundColor(.red)
                        .padding(5)
                } else {
                    Text("\(display.day == 1 ? day.date.month + " " : "")\(display.day!)")
                        .font(.system(.title2, design: .rounded))
                        .foregroundColor(day.currentMonth ? .white : .gray)
                        .padding(5)
                }

                Spacer()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: {
            showNewEventPopup = true
        })
        .popover(isPresented: $showNewEventPopup, content: {
            CalendarEventAddingView(input: day.date)
        })
    }
}
