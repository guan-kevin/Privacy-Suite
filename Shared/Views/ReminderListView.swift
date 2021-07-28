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
        ReminderFilteredListView(showCompleted: showCompleted, item: item)
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
    @FetchRequest var reminders: FetchedResults<ReminderItem>

    init(showCompleted: Bool, item: ReminderListItem) {
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

    var body: some View {
        if reminders.count == 0 {
            Text("No reminder in this list")
        } else {
            List {
                ForEach(reminders) { reminder in
                    ReminderItemView(item: reminder)
                }
            }
        }
    }
}
