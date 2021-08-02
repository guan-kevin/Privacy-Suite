//
//  CalendarEventAddingView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 8/1/21.
//

import SwiftUI

struct CalendarEventAddingView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var storage: CalendarItemStorage
    @ObservedObject var item: CalendarListItem

    let input: Date

    @State var title = ""
    @State var allDay = false
    @State var start = Date()
    @State var end = Date()

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Title", text: $title)

            Toggle(isOn: $allDay, label: {
                Text("All-day")
            })

            if allDay {
                DatePicker(
                    "Starts",
                    selection: $start,
                    displayedComponents: [.date]
                )

                DatePicker(
                    "Ends",
                    selection: $end,
                    displayedComponents: [.date]
                )
            } else {
                DatePicker(
                    "Starts",
                    selection: $start,
                    displayedComponents: [.date, .hourAndMinute]
                )

                DatePicker(
                    "Ends",
                    selection: $end,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }

            HStack {
                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                }

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    storage.addEvent(list: item, title: title, starts: start, ends: end)
                }) {
                    Text("Add")
                }
            }
        }
        .padding()
        .onChange(of: start, perform: { _ in
            updateStartEnd(changeStart: true)
        })
        .onChange(of: end, perform: { _ in
            updateStartEnd(changeStart: false)
        })
        .onAppear {
            start = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: input)!
            end = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: input)!
        }
    }

    func updateStartEnd(changeStart: Bool) {
        if start > end {
            if changeStart {
                end = start
            } else {
                start = end
            }
        }
    }
}
