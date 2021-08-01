//
//  NotesView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/18/21.
//

import SwiftUI

struct NotesView: View {
    @EnvironmentObject var storage: NoteItemStorage

    @State var showAddNote = false

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
                .listStyle(InsetGroupedListStyle())
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddNote = true
                }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddNote, content: {
            DialogTextField(title: "New Note", textFieldTitle: "Title") { result in
                guard result != "" else {
                    return
                }

                addNewNote(title: result)
            }
        })
        .onAppear {
            if UIDevice.current.userInterfaceIdiom == .pad {
                if storage.selection == nil {
                    storage.selection = storage.notes.first?.id
                }
            }
        }
        .onDisappear {
            if UIDevice.current.userInterfaceIdiom == .pad {
                if storage.selection == nil {
                    storage.selection = storage.defaultSelection
                }
            }
        }
    }

    private func addNewNote(title: String) {
        withAnimation {
            storage.add(title: title, content: "")
        }
    }
}
