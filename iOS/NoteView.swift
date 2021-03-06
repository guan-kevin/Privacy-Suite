//
//  NoteView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/21/21.
//

import SwiftUI

struct NoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var storage: NoteItemStorage

    @ObservedObject var item: NoteItem

    @State var title: String = ""
    @State var content: String = ""

    @State var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Title", text: $title) { _ in } onCommit: {
                if title != item.getTitle() {
                    storage.edit(item: item, title: title, content: content)
                }
            }
            .font(.system(.title, design: .rounded))
            .textFieldStyle(PlainTextFieldStyle())
            .background(Color.clear)

            TextEditor(text: $content)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .font(.body)
                .background(Color.red)
                .onChange(of: content) { _ in
                    if storage.shouldAutoSave {
                        storage.detector.send()
                    }
                    storage.shouldAutoSave = true
                }
                .onReceive(storage.publisher) {
                    save()
                }

            Spacer()
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("\(item.lastEdited ?? Date(), formatter: itemFormatter)")
                    .font(.footnote)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showDeleteAlert, content: {
            Alert(title: Text("Are you sure you want to delete this note?"), message: Text("You can???t undo this action."), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete"), action: {
                delete()
            }))
        })
        .onChange(of: item.lastEdited, perform: { _ in
            storage.shouldAutoSave = false
            
            self.title = item.getTitle()
            self.content = item.getContent()
        })
        .onAppear {
            storage.shouldAutoSave = true
            
            self.title = item.getTitle()
            self.content = item.getContent()
        }
        .onDisappear {
            save()
        }
    }

    func save() {
        if content != item.getContent() {
            storage.edit(item: item, title: title, content: content)
        }
    }

    func delete() {
        presentationMode.wrappedValue.dismiss()

        if UIDevice.current.userInterfaceIdiom == .pad {
            for i in 0 ..< storage.notes.count {
                if storage.notes[i].id == item.id {
                    if i == 0 {
                        if storage.notes.count <= 1 {
                            // deleting the last item
                            storage.selection = storage.defaultSelection
                        } else {
                            // deleting the first but not last
                            storage.selection = storage.notes[1].id
                        }
                    } else {
                        storage.selection = storage.notes[i - 1].id
                    }
                    break
                }
            }
        } else {
            storage.selection = nil
        }

        storage.delete(by: item)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
