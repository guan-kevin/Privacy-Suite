//
//  ContentView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/18/21.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            Group {
                if selectedTab == 0 {
                    NotesView()
                } else if selectedTab == 1 {
                    RemindersView()
                } else if selectedTab == 2 {
                    CalenderView()
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 220, maxWidth: 220)
            .toolbar {
                ToolbarItemGroup {
                    Button(action: {
                        toggleSidebar()
                    }, label: {
                        Image(systemName: "sidebar.left")
                    })

                    Spacer()

                    Menu {
                        Button(action: {
                            selectedTab = 0
                        }) {
                            Text("Notes")
                        }

                        Button(action: {
                            selectedTab = 1
                        }) {
                            Text("Reminders")
                        }

                        Button(action: {
                            selectedTab = 2
                        }) {
                            Text("Calender")
                        }
                    }
                    label: {
                        Image(systemName: getIcon())
                    }
                }
            }

            Text("Select an item")
        }
        .navigationTitle(getTitle())
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .frame(minWidth: 800, minHeight: 400)
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }

    private func getTitle() -> String {
        switch selectedTab {
        case 0:
            return "Notes"
        case 1:
            return "Reminders"
        case 2:
            return "Calender"
        default:
            return "Default"
        }
    }

    private func getIcon() -> String {
        switch selectedTab {
        case 0:
            return "note.text"
        case 1:
            return "list.bullet.rectangle"
        case 2:
            return "calendar"
        default:
            return "questionmark.square"
        }
    }
}

extension NSTextField {
    override open var focusRingType: NSFocusRingType {
        get { .none }
        set {}
    }
}
