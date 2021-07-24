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
            NavigationLink(destination: SelectNoteView(), tag: storage.defaultSelection, selection: $storage.selection) {
                EmptyView()
            }
            .hidden()
        )
        .onAppear {
            if let id = storage.notes.first?.id {
                storage.selection = id
            } else {
                storage.selection = storage.defaultSelection
            }
        }
        .onDisappear {
            storage.selection = storage.defaultSelection
        }
    }
}

struct SelectNoteView: View {
    @EnvironmentObject var storage: NoteItemStorage
    @State var showAddNote = false

    var body: some View {
        Text("Select an item!!")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showAddNote = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddNote, content: {
                DialogTextField(title: "New Note", textFieldTitle: "Title") { result in
                    guard result != "" else {
                        return
                    }

                    withAnimation {
                        storage.add(title: result, content: "")
                    }
                }
            })
    }
}
