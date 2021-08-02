//
//  CalendarListView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 8/1/21.
//

import SwiftUI

struct CalendarListView: View {
    @State var item: CalendarListItem

    init(item: CalendarListItem) {
        _item = State(initialValue: item)
    }

    var body: some View {
        content
    }

    var content: some View {
        CalendarFilteredListView(title: item.name ?? "", item: item)
    }
}

struct CalendarFilteredListView: View {
    let title: String

    @FetchRequest var events: FetchedResults<CalendarEventItem>
    @State var currentDate = ""
    @ObservedObject var item: CalendarListItem

    let timer = Timer.publish(every: 60, tolerance: 30, on: .main, in: .common).autoconnect()

    init(title: String, item: CalendarListItem) {
        self.title = title
        let predicate = NSPredicate(format: "list == %@", item)

        _events = FetchRequest(
            entity: CalendarEventItem.entity(),
            sortDescriptors: [],
            predicate: predicate
        )

        _item = ObservedObject(wrappedValue: item)
    }

    var body: some View {
        CalendarTableView(item: item, events: events.map { $0 }, currentDate: currentDate)
            .onReceive(timer) { result in
                let current = Calendar.current.dateComponents([.year, .month, .day], from: result)
                currentDate = "\(current.year!):\(current.month!)\(current.day!)"
            }
            .onAppear {
                let current = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                currentDate = "\(current.year!):\(current.month!)\(current.day!)"
            }
    }
}
