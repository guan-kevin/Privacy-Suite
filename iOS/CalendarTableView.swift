//
//  CalendarTableView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/29/21.
//

import SwiftUI

struct CalendarTableView: View {
    @EnvironmentObject var storage: CalendarItemStorage

    @State var events: [CalendarEventItem]
    @State var date = Date()
    @State var days: [CalendarDate] = []

    @State var selectedDate: Int?

    var currentDate: String

    let weeks = [
        "S", "M", "T", "W", "T", "F", "S"
    ]

    let longWeeks = [
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

    var body: some View {
        Group {
            // Portrait
            if !storage.isLandscape {
                portraitView
            } else {
                landscapeView
            }
        }
        .navigationTitle("\(date.fullMonth) \(String(Calendar.current.component(.year, from: date)))")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            prepareCalendar()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    selectedDate = nil
                    lastMonth()
                }) {
                    Image(systemName: "chevron.left")
                }

                Button(action: {
                    selectedDate = nil
                    today()
                }) {
                    Image(systemName: "calendar")
                }

                Button(action: {
                    selectedDate = nil
                    nextMonth()
                }) {
                    Image(systemName: "chevron.right")
                }
            }
        }
    }

    var eventList: some View {
        Group {
            if selectedDate == nil {
                VStack {
                    Spacer()
                    Text("Select a date")
                    Spacer()
                }
            } else {
                List {
                    Text("Dummy Date")
                    Text("Dummy Date")
                    Text("Dummy Date")
                    Text("Dummy Date")
                    Text("Dummy Date")
                    Text("Dummy Date")
                    Text("Dummy Date")
                    Text("Dummy Date")
                    Text("Dummy Date")
                    Text("Dummy Date")
                }
                .padding(.top, 5)
            }
        }
    }

    var portraitView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(weeks, id: \.self) { week in
                    Spacer()

                    Text(week)
                        .font(.system(size: 12, weight: .medium, design: .rounded))

                    Spacer()
                }
            }
            .padding(.vertical, 5)

            Divider()

            GeometryReader { proxy in
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0 ..< days.count, id: \.self) { day in
                        if selectedDate == day {
                            ZStack(alignment: .center) {
                                Circle().fill(Color.orange).frame(width: 40)

                                CalendarDayView(day: days[day], currentDate: currentDate)
                                    .contentShape(Rectangle())
                                    .frame(height: proxy.size.width / 7)
                            }
                            .contextMenu {
                                Button(action: {}) {
                                    Label("Add Event", systemImage: "plus")
                                }
                            }
                            .onTapGesture {
                                selectedDate = day
                            }
                        } else {
                            CalendarDayView(day: days[day], currentDate: currentDate)
                                .contentShape(Rectangle())
                                .frame(height: proxy.size.width / 7)
                                .contextMenu {
                                    Button(action: {}) {
                                        Label("Add Event", systemImage: "plus")
                                    }
                                }
                                .onTapGesture {
                                    selectedDate = day
                                }
                        }
                    }
                }
                .frame(height: proxy.size.width * 6 / 7)
            }

            eventList
        }
    }

    var landscapeView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(longWeeks, id: \.self) { week in
                    Spacer()

                    Text(week)
                        .font(.system(size: 12, weight: .medium, design: .rounded))

                    Spacer()
                }
            }
            .padding(.vertical, 5)

            GeometryReader { proxy in
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0 ..< days.count, id: \.self) { day in
                        LandscapeCalendarDayView(day: days[day], currentDate: currentDate)
                            .background(Rectangle().stroke().foregroundColor(Color.gray))
                            .frame(height: proxy.size.height / 6)
                    }
                }
                .frame(height: proxy.size.height)
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
