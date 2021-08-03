//
//  CalendarDayView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/31/21.
//

import SwiftUI

struct CalendarDayView: View {
    var allEvents: [CalendarEventItem]
//    @ObservedObject var model: CalendarTableViewModel
    @ObservedObject var item: CalendarListItem
    let day: CalendarDate
    let currentDate: String

    @State var showNewEventPopup = false

    @State var events: [CalendarEventItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let display = Calendar.current.dateComponents([.year, .month, .day], from: day.date)

            HStack {
                Spacer()

                if currentDate == "\(display.year!):\(display.month!)\(display.day!)" {
                    Text("\(display.day == 1 ? day.date.month + " " : "")\(display.day!)")
                        .font(.system(.title2, design: .rounded))
                        .foregroundColor(.red)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                } else {
                    Text("\(display.day == 1 ? day.date.month + " " : "")\(display.day!)")
                        .font(.system(.title2, design: .rounded))
                        .foregroundColor(day.currentMonth ? .white : .gray)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                }
            }

            if events.count > 0 {
                Text(events.first!.getTitle())
                    .padding(.horizontal, 5)
                    .font(.system(size: 11))

                if events.count > 1 {
                    Text("\(events.count - 1) more...")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 5)
                        .font(.system(size: 11))
                }
            }

            Spacer()
        }
        .onChange(of: allEvents, perform: { new in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let calendar = Calendar.current
                let cell = calendar.startOfDay(for: day.date) ... calendar.date(bySettingHour: 23, minute: 59, second: 59, of: day.date)!

                self.events = new.filter { cell.overlaps($0.getStart() ... $0.getEnd()) }
            }
        })
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let calendar = Calendar.current
                let cell = calendar.startOfDay(for: day.date) ... calendar.date(bySettingHour: 23, minute: 59, second: 59, of: day.date)!

                self.events = allEvents.filter { cell.overlaps($0.getStart() ... $0.getEnd()) }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: {
            showNewEventPopup = true
        })
        .popover(isPresented: $showNewEventPopup, content: {
            CalendarEventAddingView(item: item, input: day.date)
        })
    }
}
