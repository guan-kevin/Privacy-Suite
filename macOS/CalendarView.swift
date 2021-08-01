//
//  CalendarView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/22/21.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var storage: CalendarItemStorage

    @State var showAddList = false
    @State var showAddError = false
    @State var selectedDeleteList: CalendarListItem? = nil

    var body: some View {
        Group {
            if storage.list.count == 0 {
                VStack(spacing: 0) {
                    Spacer()

                    Text("You don't have any calendar")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                    Spacer()
                    HStack {
                        Button(action: {
                            showAddList = true
                        }) {
                            Label("Add Calendar", systemImage: "plus.circle")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(8)
                        .foregroundColor(.gray)

                        Spacer()
                    }
                }
            } else {
                VStack(spacing: 0) {
                    List(selection: self.$storage.selection) {
                        ForEach(storage.list) { item in
                            NavigationLink(destination: LazyView(CalendarListView(item: item)), tag: item.id, selection: $storage.selection) {
                                Text(item.listName)
                            }
                            .contextMenu {
                                Button(action: {
                                    selectedDeleteList = item
                                }) {
                                    Text("Delete")
                                }
                            }
                        }
                    }

                    HStack {
                        Button(action: {
                            showAddList = true
                        }) {
                            Label("Add Calendar", systemImage: "plus.circle")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(8)
                        .foregroundColor(.gray)

                        Spacer()
                    }
                }
            }
        }
        .background(
            Group {
                NavigationLink(destination: Text("Select a calendar!"), tag: storage.defaultSelection, selection: $storage.selection) {
                    EmptyView()
                }
                .hidden()

                Text("")
                    .frame(width: 0, height: 0)
                    .alert(isPresented: $showAddError, content: {
                        Alert(title: Text("Calendar already exists"))
                    })

                Text("")
                    .frame(width: 0, height: 0)
                    .alert(item: $selectedDeleteList, content: { item in
                        Alert(title: Text("Are you sure you want to delete \(item.listName) and all the events inside this calendar?"), message: Text("You can’t undo this action."), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete"), action: {
                            deleteList(name: item.listName)
                        }))
                    })
            }
        )
        .sheet(isPresented: $showAddList, content: {
            DialogTextField(title: "New Calendar", textFieldTitle: "Name") { result in
                guard result != "" else {
                    return
                }

                addNewList(name: result)
            }
        })
        .onAppear {
            storage.selection = storage.list.first?.id
        }
        .onDisappear {
            storage.selection = storage.defaultSelection
        }
    }

    private func addNewList(name: String) {
        let exists = storage.list.filter { $0.listName == name }

        if exists.isEmpty {
            storage.createList(name: name)
            return
        }

        showAddError = true
    }

    private func deleteList(name: String) {
        selectedDeleteList = nil

        for i in 0 ..< storage.list.count {
            if storage.list[i].listName == name {
                if i == 0 {
                    if storage.list.count <= 1 {
                        // deleting the last item
                        storage.selection = storage.defaultSelection
                    } else {
                        // deleting the first but not last
                        storage.selection = storage.list[1].id
                    }
                } else {
                    storage.selection = storage.list[i - 1].id
                }
                break
            }
        }

        storage.deleteList(name: name)
    }
}
