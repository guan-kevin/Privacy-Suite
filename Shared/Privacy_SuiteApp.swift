//
//  Privacy_SuiteApp.swift
//  Shared
//
//  Created by Kevin Guan on 7/18/21.
//

import SwiftUI

@main
struct Privacy_SuiteApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var noteStorage: NoteItemStorage
    @StateObject var reminderStorage: ReminderItemStorage
    @StateObject var calendarStorage: CalendarItemStorage
    @StateObject var lockedViewModel = LockedViewModel()

    init() {
        let noteStorage = NoteItemStorage(managedObjectContext: PersistenceController.shared.container.viewContext)
        self._noteStorage = StateObject(wrappedValue: noteStorage)

        let reminderStorage = ReminderItemStorage(managedObjectContext: PersistenceController.shared.container.viewContext)
        self._reminderStorage = StateObject(wrappedValue: reminderStorage)

        let calendarStorage = CalendarItemStorage(managedObjectContext: PersistenceController.shared.container.viewContext)
        self._calendarStorage = StateObject(wrappedValue: calendarStorage)
    }

    var body: some Scene {
        WindowGroup {
            if lockedViewModel.appLocked {
                LockedView(model: lockedViewModel)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.lockedViewModel.unlock()
                        }
                    }
            } else {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(noteStorage)
                    .environmentObject(reminderStorage)
                    .environmentObject(calendarStorage)
                    .onAppear {
                        noteStorage.fetchNotes()
                        reminderStorage.fetchList()
                        calendarStorage.fetchList()
                    }
            }
        }
    }
}
