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

    @Environment(\.scenePhase) var scenePhase
    @StateObject var noteStorage: NoteItemStorage
    @StateObject var lockedViewModel = LockedViewModel()

    init() {
        let storage = NoteItemStorage(managedObjectContext: PersistenceController.shared.container.viewContext)
        self._noteStorage = StateObject(wrappedValue: storage)
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
                    .onAppear {
                        noteStorage.fetchNotes()
                    }
            }
        }
        .onChange(of: scenePhase) { value in
            if value == .background {
                persistenceController.save()
            }
        }
    }
}
