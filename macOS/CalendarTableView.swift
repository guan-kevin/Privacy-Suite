//
//  CalendarTableView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/29/21.
//

import SwiftUI

struct CalendarTableView: View {
    @ObservedObject var item: CalendarListItem

    @State var date = Date()
    @State var days: [CalendarDate] = []

    var currentDate: String

    var events: [CalendarEventItem] = []

    let weeks = [
        "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
    ]

    let columns = [
        GridItem(.flexible(), spacing: 0, alignment: .center),
        GridItem(.flexible(), spacing: 0, alignment: .center),
        GridItem(.flexible(), spacing: 0, alignment: .center),
        GridItem(.flexible(), spacing: 0, alignment: .center),
        GridItem(.flexible(), spacing: 0, alignment: .center),
        GridItem(.flexible(), spacing: 0, alignment: .center),
        GridItem(.flexible(), spacing: 0, alignment: .center)
    ]

    init(item: CalendarListItem, events: [CalendarEventItem], currentDate: String) {
        _item = ObservedObject(wrappedValue: item)
        self.currentDate = currentDate
        self.events = events
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(weeks, id: \.self) { week in
                    Spacer()

                    Text(week)
                        .padding(.trailing, 10)
                        .font(.system(size: 20, weight: .light, design: .rounded))
                }
            }
            GeometryReader { proxy in
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(days) { day in
                        CalendarDayView(allEvents: events, item: item, day: day, currentDate: currentDate)
                            .background(Rectangle().stroke().foregroundColor(Color.gray))
                            .frame(height: proxy.size.height / 6)
                    }
                }
                .frame(height: proxy.size.height)
            }
        }
        .navigationTitle("\(date.fullMonth) \(String(Calendar.current.component(.year, from: date)))")
        .onAppear {
            prepareCalendar()
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    lastMonth()
                }) {
                    Image(systemName: "chevron.left")
                }
                Button(action: {
                    today()
                }) {
                    Text("Today")
                }
                .buttonStyle(PlainButtonStyle())
                Button(action: {
                    nextMonth()
                }) {
                    Image(systemName: "chevron.right")
                }
            }
        }
    }

    func prepareCalendar() {
        // find start of month
        let start = date.startOfMonth()
        let count = date.daysPerMonth()

        var temp: [CalendarDate] = []
        for i in -start.weekday + 1 ..< -start.weekday + 43 {
            temp.append(CalendarDate(date: Calendar.current.date(byAdding: .day, value: i, to: start.date)!, currentMonth: i >= 0 && i < count))
        }

        days = temp
    }

    func lastMonth() {
        date = Calendar.current.date(byAdding: .month, value: -1, to: date)!
        prepareCalendar()
    }

    func today() {
        date = Date()
        prepareCalendar()
    }

    func nextMonth() {
        date = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        prepareCalendar()
    }
}
