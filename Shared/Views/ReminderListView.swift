//
//  ReminderListView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/22/21.
//

import SwiftUI

struct ReminderListView: View {
    @State var item: ReminderListItem

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
                List {
                    ForEach(item.reminderArray) { reminder in
                        ReminderItemView(item: reminder)
                    }
                }
            }

            ReminderListToolbarView(item: item)
                .frame(width: 0, height: 0)
        }
    }
}

struct ReminderListToolbarView: View {
    @EnvironmentObject var storage: ReminderItemStorage
    let item: ReminderListItem

    var body: some View {
        Text("")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {
                        storage.addReminder(list: item)
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                storage.focus = nil
            }
    }
}
