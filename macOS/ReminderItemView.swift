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
    let currentDate: Date

    @State var title: String = ""
    @State var note: String = ""

    @State var completed: Bool = false

    @State var date: Date?
    @State var priority: Int16 = 0

    @State var showSettings = false
    @State var showInfo = false

    var body: some View {
        Group {
            focused
                .onHover(perform: { hovering in
                    showInfo = hovering
                })
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

    @State var focus = false

    var focused: some View {
        HStack {
            VStack {
                completedButton
                Spacer()
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    FocusableTextField(stringValue: $title, placeholder: "Title", focus: $focus, onCommit: {
                        storage.detector.send()
                    })
                        .onAppear {
                            if storage.focus == item.id {
                                focus = true
                                storage.focus = nil
                            }
                        }

                    Spacer()

                    if showInfo || showSettings {
                        infoButton
                    }
                }
                .padding(.trailing, 5)

                TextField("Note", text: $note, onCommit: {
                    storage.detector.send()
                })
                    .foregroundColor(.gray)
                    .font(.callout)
                    .textFieldStyle(PlainTextFieldStyle())
                    .background(Color.clear)
                    .padding(.trailing, 5)

                if let date = date, date < currentDate {
                    Text(date, formatter: itemFormatter)
                        .foregroundColor(.red)
                        .padding(.trailing, 5)
                }
                Divider()
            }
        }
        .padding(.leading, 5)
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
            print("Saving reminder")
            storage.editReminder(item: item, title: title, notes: note, date: date, priority: priority, completed: completed)
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

// Source: https://serialcoder.dev/text-tutorials/macos-tutorials/macos-programming-implementing-a-focusable-text-field-in-swiftui/
struct FocusableTextField: NSViewRepresentable {
    @Binding var stringValue: String
    var placeholder: String
    var autoFocus = false
    var focus: Binding<Bool>
    var onChange: (() -> Void)?
    var onCommit: (() -> Void)?
    var onTabKeystroke: (() -> Void)?
    @State private var didFocus = false

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.stringValue = stringValue
        textField.placeholderString = placeholder
        textField.delegate = context.coordinator
        textField.drawsBackground = false
        textField.isBezeled = false
        textField.font = NSFont.systemFont(ofSize: 16)
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = stringValue

        if autoFocus && !didFocus {
            NSApplication.shared.mainWindow?.perform(
                #selector(NSApplication.shared.mainWindow?.makeFirstResponder(_:)),
                with: nsView,
                afterDelay: 0.0
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                didFocus = true
            }
        }

        if focus.wrappedValue {
            NSApplication.shared.mainWindow?.perform(
                #selector(NSApplication.shared.mainWindow?.makeFirstResponder(_:)),
                with: nsView,
                afterDelay: 0.0
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.focus.wrappedValue = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: FocusableTextField

        init(with parent: FocusableTextField) {
            self.parent = parent
            super.init()

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleAppDidBecomeActive(notification:)),
                                                   name: NSApplication.didBecomeActiveNotification,
                                                   object: nil)
        }

        @objc
        func handleAppDidBecomeActive(notification: Notification) {
            if parent.autoFocus && !parent.didFocus {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.parent.didFocus = false
                }
            }
        }

        // MARK: - NSTextFieldDelegate Methods

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            parent.stringValue = textField.stringValue
            parent.onChange?()
        }

        func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
            parent.stringValue = fieldEditor.string
            parent.onCommit?()
            return true
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSStandardKeyBindingResponding.insertTab(_:)) {
                parent.onTabKeystroke?()
                return true
            }
            return false
        }
    }
}
