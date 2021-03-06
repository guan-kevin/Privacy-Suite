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

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()

                let display = Calendar.current.dateComponents([.year, .month, .day], from: day.date)

                if currentDate == "\(display.year!):\(display.month!)\(display.day!)" {
                    if display.day == 1 {
                        Text("\(day.date.month) ")
                            .font(.system(size: 10, weight: .regular, design: .rounded))
                            .foregroundColor(.red)
                            +
                            Text("\(display.day!)")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.red)
                    } else {
                        Text("\(display.day!)")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.red)
                    }
                } else {
                    if display.day == 1 {
                        Text("\(day.date.month) ")
                            .font(.system(size: 10, weight: .regular, design: .rounded))
                            .foregroundColor(day.currentMonth ? .white : .gray)
                            +
                            Text("\(display.day!)")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(day.currentMonth ? .white : .gray)
                    } else {
                        Text("\(display.day!)")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(day.currentMonth ? .white : .gray)
                    }
                }

                Spacer()
            }

            Spacer()
        }
    }
}

struct LandscapeCalendarDayView: View {
    let day: CalendarDate
    let currentDate: String

    var body: some View {
        HStack {
            Spacer()
            VStack {
                let display = Calendar.current.dateComponents([.year, .month, .day], from: day.date)

                if currentDate == "\(display.year!):\(display.month!)\(display.day!)" {
                    Text("\(display.day == 1 ? day.date.month + " " : "")\(display.day!)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.red)
                        .padding(5)
                } else {
                    Text("\(display.day == 1 ? day.date.month + " " : "")\(display.day!)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(day.currentMonth ? .white : .gray)
                        .padding(5)
                }

                Spacer()
            }
        }
    }
}
