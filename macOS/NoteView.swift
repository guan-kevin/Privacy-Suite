//
//  NoteView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/18/21.
//

import Combine
import SwiftUI

struct NoteView: View {
    @EnvironmentObject var storage: NoteItemStorage
    private let tabs = ["Notes", "Reminders", "Calendar"]
    @State var item: NoteItem

    @State var title: String = ""
    @State var content: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text("\(item.lastEdited ?? Date(), formatter: itemFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }

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

            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: {
                    if item.id == storage.notes.first?.id {
                        storage.selection = storage.defaultSelection
                    } else {
                        storage.selection = storage.notes.first?.id
                    }
                    storage.delete(by: item)
                }) {
                    Text("Delete")
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
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
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
