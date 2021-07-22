//
//  NotesView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/18/21.
//

import SwiftUI

struct NotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var storage: NoteItemStorage

    var body: some View {
        Group {
            if storage.notes.count == 0 {
                Text("You don't have any notes")
                    .multilineTextAlignment(.center)
                    .font(.headline)
            } else {
                List(selection: self.$storage.selection) {
                    ForEach(storage.notes) { item in
                        NavigationLink(destination: LazyView(NoteView(item: item)), tag: item.id, selection: $storage.selection) {
                            Text(item.getTitle())
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .navigationBarTitleDisplayMode(.automatic)
        .navigationTitle(Text("Notes"))
        .background(
            NavigationLink(destination: Text("Select an item!"), tag: storage.defaultSelection, selection: $storage.selection) {
                EmptyView()
            }
            .hidden()
        )
        .onAppear {
            if UIDevice.current.userInterfaceIdiom == .pad {
                storage.selection = storage.notes.first?.id
            }
        }
        .onDisappear {
            if UIDevice.current.userInterfaceIdiom == .pad {
                storage.selection = storage.defaultSelection
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            storage.add(title: "This is a title", content: "This is a body")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            storage.delete(by: offsets)
        }
    }
}
