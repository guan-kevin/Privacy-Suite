//
//  RemindersView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/22/21.
//

import SwiftUI

struct RemindersView: View {
    @EnvironmentObject var storage: ReminderItemStorage

    @State var showAddList = false
    @State var showAddError = false
    
    @State var showDeleteList = false
    @State var deleteID: ObjectIdentifier? = nil

    var body: some View {
        Group {
            if storage.list.count == 0 {
                Text("You don't have any list")
                    .multilineTextAlignment(.center)
                    .font(.headline)
            } else {
                List(selection: self.$storage.selection) {
                    ForEach(storage.list) { item in
                        NavigationLink(destination: LazyView(ReminderListView(item: item)), tag: item.id, selection: $storage.selection) {
                            Text(item.listName)
                        }
                        .contextMenu {
                            Button(action: {
                                deleteID = item.id
                                showDeleteList = true
                            }) {
                                Text("Delete")
                            }
                        }
                    }
                }
            }
        }
        .background(
            Group {
                NavigationLink(destination: Text("Select a list!"), tag: storage.defaultSelection, selection: $storage.selection) {
                    EmptyView()
                }
                .hidden()

                Text("")
                    .frame(width: 0, height: 0)
                    .alert(isPresented: $showAddError, content: {
                        Alert(title: Text("List already exists"))
                    })

                Text("")
                    .frame(width: 0, height: 0)
                    .alert(isPresented: $showDeleteList, content: {
                        Alert(title: Text("Are you sure you want to delete this list and all the reminders inside this list?"), message: Text("You can’t undo this action."), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete"), action: {
                            deleteList()
                        }))
                    })
            }
        )
        .sheet(isPresented: $showAddList, content: {
            DialogTextField(title: "New List", textFieldTitle: "Name") { result in
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
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    showAddList.toggle()
                }) {
                    Image(systemName: "plus")
                }
            }
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

    private func deleteList() {
        guard let deleteID = deleteID else { return }
        for i in 0 ..< storage.list.count {
            if storage.list[i].id == deleteID {
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

        showDeleteList = false
        storage.deleteList(id: deleteID)
    }
}
