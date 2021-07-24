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

    var body: some View {
        Group {
            if item.reminderArray.count == 0 {
                Text("No reminder in this list")
            } else {
                List {
                    ForEach(item.reminderArray) { reminder in
                        Text(reminder.getTitle())
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: getToolbarItemPlacement()) {
                Button(action: {
//                    showAddList.toggle()
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }

    func getToolbarItemPlacement() -> ToolbarItemPlacement {
        #if os(iOS)
        return .primaryAction
        #endif
        return .navigation
    }
}
