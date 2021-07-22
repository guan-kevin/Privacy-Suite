//
//  NoteView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/21/21.
//

import SwiftUI

struct NoteView: View {
    @EnvironmentObject var storage: NoteItemStorage

    @State var item: NoteItem

    @State var title: String = ""
    @State var content: String = ""

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

            Spacer()
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("\(item.lastEdited ?? Date(), formatter: itemFormatter)")
                    .font(.footnote)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: item.lastEdited, perform: { _ in
            self.title = item.getTitle()
            self.content = item.getContent()
        })
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
