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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
