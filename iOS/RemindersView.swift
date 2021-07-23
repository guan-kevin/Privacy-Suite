//
//  RemindersView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/22/21.
//

import SwiftUI

struct RemindersView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var storage: ReminderItemStorage

    @State var showAddList = false
    @State var showAddError = false

    @State var selectedDeleteList: ReminderListItem? = nil

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
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            selectedDeleteList = storage.list[index]
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationBarTitleDisplayMode(.automatic)
        .navigationTitle(Text("Reminders"))
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
                    .alert(item: $selectedDeleteList, content: { item in
                        Alert(title: Text("Are you sure you want to delete \(item.listName) and all the reminders inside this list?"), message: Text("You can’t undo this action."), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete"), action: {
                            deleteList(name: item.listName)
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
            if UIDevice.current.userInterfaceIdiom == .pad {
                storage.selection = storage.list.first?.id
            }
        }
        .onDisappear {
            if UIDevice.current.userInterfaceIdiom == .pad {
                storage.selection = storage.defaultSelection
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
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

        print("SHOW ERROR")
        showAddError = true
    }

    private func deleteList(name: String) {
        selectedDeleteList = nil

        if UIDevice.current.userInterfaceIdiom == .pad {
            presentationMode.wrappedValue.dismiss()
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
        }

        storage.deleteList(name: name)
    }
}
