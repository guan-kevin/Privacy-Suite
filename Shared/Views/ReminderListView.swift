//
//  ReminderListView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/22/21.
//

import SwiftUI

struct ReminderListView: View {
    @EnvironmentObject var storage: ReminderItemStorage
    @State var item: ReminderListItem
    @State var showCompleted = false

    init(item: ReminderListItem) {
        _item = State(initialValue: item)
    }

    var body: some View {
        #if os(iOS)
        content
            .navigationBarTitleDisplayMode(.inline)
        #elseif os(macOS)
        content
        #endif
    }

    var content: some View {
        ReminderFilteredListView(title: item.name ?? "", showCompleted: showCompleted, item: item)
            .toolbar {
                ToolbarItemGroup(placement: getToolbarItemPlacement()) {
                    Button(action: {
                        showCompleted.toggle()
                    }) {
                        Image(systemName: showCompleted ? "text.badge.xmark" : "text.badge.checkmark")
                    }

                    Button(action: {
                        storage.addReminder(list: item)
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
    }

    func getToolbarItemPlacement() -> ToolbarItemPlacement {
        #if os(iOS)
        return .navigationBarTrailing
        #elseif os(macOS)
        return .primaryAction
        #endif
    }
}

struct ReminderFilteredListView: View {
    let title: String
    @FetchRequest var reminders: FetchedResults<ReminderItem>
    @State var currentDate = Date()
    let timer = Timer.publish(every: 60, tolerance: 30, on: .main, in: .common).autoconnect()

    init(title: String, showCompleted: Bool, item: ReminderListItem) {
        self.title = title
        var predicate = NSPredicate(format: "list == %@", item)

        if !showCompleted {
            predicate = NSPredicate(format: "list == %@ AND completed == %@", item, NSNumber(value: false))
        }

        _reminders = FetchRequest(
            entity: ReminderItem.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \ReminderItem.completed, ascending: false),
                NSSortDescriptor(keyPath: \ReminderItem.priority, ascending: false),
                NSSortDescriptor(keyPath: \ReminderItem.dateCreated, ascending: true)
            ],
            predicate: predicate
        )
    }

    #if os(iOS)
    var body: some View {
        if reminders.count == 0 {
            Text("No reminder in this list")
        } else {
            List {
                ForEach(reminders) { reminder in
                    ReminderItemView(item: reminder, currentDate: currentDate)
                }
            }
            .onReceive(timer) { result in
                currentDate = result
            }
            .navigationTitle(title)
        }
    }

    #elseif os(macOS)
    @State var viewDidAppear = false
    var body: some View {
        if reminders.count == 0 {
            Text("No reminder in this list")
        } else {
            ScrollView {
                if viewDidAppear {
                    LazyVStack {
                        ForEach(reminders) { reminder in
                            ReminderItemView(item: reminder, currentDate: currentDate)
                        }
                    }
                }
            }
            .onAppear {
                // fixed action tried to update multiple times per frame.
                viewDidAppear = true
            }
            .onReceive(timer) { result in
                currentDate = result
            }
        }
    }
    #endif
}
