//
//  ReminderItemView.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/24/21.
//

import Introspect
import SwiftUI

struct ReminderItemView: View {
    @EnvironmentObject var storage: ReminderItemStorage

    @State var item: ReminderItem

    @State var title: String = ""
    @State var note: String = ""

    @State var completed: Bool = false

    @State var date: Date?

    @State var priority: Int16 = 0
    @State var setPriority = false

    @State var showSettings = false
    @State var showInfo = false

    var body: some View {
        Group {
            focused
                .onHover(perform: { hovering in
                    showInfo = hovering
                })
                .onReceive(storage.publisher, perform: { _ in
                    print("Saving...")
                })
        }
        .onAppear {
            title = item.getTitle()
            note = item.getNotes()
            completed = item.isCompleted

            item.date = date

            priority = item.priority
        }
    }

    /*
     var unfocused: some View {
         HStack {
             completedButton

             VStack(alignment: .leading, spacing: 0) {
                 Spacer()

                 HStack {
                     Text(title)
                         .lineLimit(1)

                     Spacer()

                     if showInfo || showSettings {
                         infoButton
                     }
                 }

                 if let displayDate = item.date, setDate {
                     Text(displayDate, formatter: itemFormatter)
                 }

                 Spacer()

                 Divider()
             }
         }
         .contentShape(Rectangle())
         .onTapGesture {
             switchFocus()
         }
         .onHover(perform: { hovering in
             showInfo = hovering
         })
     }
     */

    var focused: some View {
        HStack {
            VStack {
                completedButton
                Spacer()
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    TextField("Title", text: $title, onCommit: {
                        storage.detector.send()
                    })
                        .font(.system(size: 16, weight: .regular, design: .rounded))

                    Spacer()

                    if showInfo || showSettings {
                        infoButton
                    }
                }

                TextField("Note", text: $note, onCommit: {
                    storage.detector.send()
                })
                    .foregroundColor(.gray)
                    .font(.callout)
                Divider()
            }
        }
    }

    var completedButton: some View {
        Button(action: {
            completed.toggle()
        }) {
            if completed {
                Image(systemName: "largecircle.fill.circle")
            } else {
                Image(systemName: "circle")
            }
        }
        .font(.title)
        .foregroundColor(.gray)
        .buttonStyle(PlainButtonStyle())
    }

    var infoButton: some View {
        Button(action: {
            showSettings = true
        }) {
            Image(systemName: "info.circle")
                .font(.system(size: 16))
        }
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $showSettings, attachmentAnchor: .point(.leading), arrowEdge: .leading, content: {
            ReminderSettingsView(date: $date, priority: $priority)
        })
    }

    func update() {
        if title != item.getTitle() || note != item.getNotes() || completed != item.isCompleted || priority != item.priority || date != item.date {
            storage.editReminder(item: item, title: title, notes: note, date: date, priority: setPriority ? Int16(0) : priority, completed: completed)
        }
    }
}

struct ReminderSettingsView: View {
    @Binding var date: Date?
    @Binding var priority: Int16

    var body: some View {
        VStack(alignment: .leading) {
            dateBar

            priorityBar
        }
        .padding()
    }

    var dateBar: some View {
        HStack(spacing: 0) {
            if date != nil {
                Button(action: {
                    date = nil
                }) {
                    Image(systemName: "xmark")
                        .padding(5)
                        .contentShape(Rectangle())
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                .cornerRadius(5)

                DatePicker(
                    "",
                    selection: Binding(get: {
                        date ?? Date()
                    }, set: { new in
                        date = new
                    }),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .frame(width: 200)
            } else {
                Button(action: {
                    date = Date()
                }) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Add Date")
                    }
                    .padding(5)
                    .contentShape(Rectangle())
                    .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                .background(Color(.displayP3, red: 0.1725, green: 0.1725, blue: 0.1725, opacity: 1))
                .cornerRadius(5)
            }
        }
    }

    var priorityBar: some View {
        HStack(spacing: 0) {
            if priority > 0 {
                Button(action: {
                    priority = Int16(0)
                }) {
                    Image(systemName: "xmark")
                        .padding(5)
                        .contentShape(Rectangle())
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                .cornerRadius(5)
                .padding(.trailing, 7)

                Picker("Priority", selection: $priority) {
                    Text("Low").tag(Int16(1))
                    Text("Medium").tag(Int16(2))
                    Text("High").tag(Int16(3))
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 250)
            } else {
                Button(action: {
                    priority = Int16(1)
                }) {
                    Image(systemName: "flag")
                        .padding(5)
                        .contentShape(Rectangle())
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                .background(Color(.displayP3, red: 0.1725, green: 0.1725, blue: 0.1725, opacity: 1))
                .cornerRadius(5)
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
