//
//  NotesView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/18/21.
//

import SwiftUI

struct NotesView: View {
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
                }
            }
        }
        .background(
            NavigationLink(destination: Text("Select an item!"), tag: storage.defaultSelection, selection: $storage.selection) {
                EmptyView()
            }
            .hidden()
        )
        .onAppear {
            storage.selection = storage.notes.first?.id
        }
        .onDisappear {
            storage.selection = storage.defaultSelection
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
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
}
