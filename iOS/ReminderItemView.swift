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

    @State var date = Date()
    @State var setDate = false

    @State var priority: Int16 = 1
    @State var setPriority = false
    

    var body: some View {
        Group {
            if storage.focus == item.id {
                focused
            } else {
                unfocused
            }
        }
        .onAppear {
            title = item.getTitle()
        }
    }

    var unfocused: some View {
        HStack {
            completedButton

            VStack(alignment: .leading, spacing: 5) {
                Spacer()

                Text(title)
                    .lineLimit(1)

                if let displayDate = item.date, setDate {
                    Text(displayDate, formatter: itemFormatter)
                }

                Spacer()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            switchFocus()
        }
    }

    var focused: some View {
        HStack {
            VStack {
                completedButton
                Spacer()
            }

            VStack(alignment: .leading, spacing: 5) {
                TextField("Title", text: $title)
                    .introspectTextField { textField in
                        textField.becomeFirstResponder()
                    }

                TextField("Note", text: $note)
                    .foregroundColor(.gray)
                    .font(.callout)

                if !setDate && !setPriority {
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
    }

    var dateBar: some View {
        HStack(spacing: 0) {
            if setDate {
                Button(action: {
                    setDate = false
                }) {
                    Image(systemName: "xmark")
                        .padding(5)
                        .contentShape(Rectangle())
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                .cornerRadius(5)
                .padding(.trailing, 12)

                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .frame(width: 180)
            } else {
                Button(action: {
                    setDate = true
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
            if setPriority {
                Button(action: {
                    priority = Int16(0)
                    setPriority = false
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
                .frame(width: 280)
            } else {
                Button(action: {
                    priority = Int16(1)
                    setPriority = true
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

    func switchFocus() {
        note = item.getNotes()
        completed = item.isCompleted

        if item.date != nil {
            date = item.date!
            setDate = true
        }

        if item.priority > 0 {
            priority = item.priority
            setPriority = true
        }

        storage.focus = item.id
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
