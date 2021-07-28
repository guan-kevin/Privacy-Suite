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

    @ObservedObject var item: ReminderItem

    @State var title: String = ""
    @State var note: String = ""

    @State var completed: Bool = false

    @State var date: Date?

    @State var priority: Int16 = 0

    @State var showSettings = false

    var body: some View {
        Group {
            focused
                .onReceive(storage.publisher, perform: { _ in
                    update()
                })
                .onChange(of: date, perform: { _ in
                    storage.detector.send()
                })
                .onChange(of: priority, perform: { _ in
                    storage.detector.send()
                })
                .onChange(of: item.title, perform: { _ in
                    self.title = item.getTitle()
                })
                .onChange(of: item.notes, perform: { _ in
                    self.note = item.getNotes()
                })
                .onChange(of: item.date, perform: { _ in
                    self.date = item.date
                })
        }
        .onAppear {
            title = item.getTitle()
            note = item.getNotes()
            completed = item.isCompleted
            date = item.date
            priority = item.priority
        }
    }

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
                        .introspectTextField(customize: { textField in
                            if storage.focus == item.id {
                                textField.becomeFirstResponder()
                                storage.focus = nil
                            }
                        })
                        .font(.system(size: 16, weight: .regular, design: .rounded))

                    Spacer()

                    infoButton
                }

                TextField("Note", text: $note, onCommit: {
                    storage.detector.send()
                })
                    .foregroundColor(.gray)
                    .font(.callout)

                if showSettings {
                    ReminderSettingsView(date: $date, priority: $priority)
                }
            }
        }
    }

    var completedButton: some View {
        Button(action: {
            completed.toggle()
            storage.detector.send()
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
            showSettings.toggle()
        }) {
            Image(systemName: "info.circle")
                .font(.system(size: 20))
        }
        .buttonStyle(PlainButtonStyle())
    }

    func update() {
        if title != item.getTitle() || note != item.getNotes() || completed != item.isCompleted || priority != item.priority || date != item.date {
            storage.editReminder(item: item, title: title, notes: note, date: date, priority: priority, completed: completed)
        }
    }
}

struct ReminderSettingsView: View {
    @Binding var date: Date?
    @Binding var priority: Int16

    var body: some View {
        Group {
            if date == nil && priority == 0 {
                HStack(alignment: .center) {
                    dateBar

                    priorityBar
                }
            } else {
                VStack(alignment: .leading) {
                    dateBar

                    priorityBar
                }
            }
        }
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
                .padding(.trailing, 5)

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
