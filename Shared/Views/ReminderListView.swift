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

    var body: some View {
        #if os(iOS)
        content
            .navigationBarTitleDisplayMode(.inline)
        #elseif os(macOS)
        content
        #endif
    }

    var content: some View {
        Group {
            if item.reminderArray.count == 0 {
                Text("No reminder in this list")
            } else {
                if showCompleted {
                    List {
                        ForEach(item.reminderArray) { reminder in
                            ReminderItemView(item: reminder)
                        }
                    }
                } else {
                    List {
                        ForEach(item.todoReminderArray) { reminder in
                            ReminderItemView(item: reminder)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
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
}
