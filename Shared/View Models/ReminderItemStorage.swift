//
//  ReminderItemStorage.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/22/21.
//

import Combine
import CoreData
import Foundation

class ReminderItemStorage: NSObject, ObservableObject {
    @Published var list: [ReminderListItem] = []

    @Published var selection: ObjectIdentifier?
    var defaultSelection = ObjectIdentifier(Dummy())

    private let controller: NSFetchedResultsController<ReminderListItem>

    var focus: ObjectIdentifier?
    let detector = PassthroughSubject<Void, Never>()
    let publisher: AnyPublisher<Void, Never>

    init(managedObjectContext: NSManagedObjectContext) {
        print("Storage INITING")
        controller = NSFetchedResultsController(fetchRequest: ReminderListItem.getFetchRequest,
                                                managedObjectContext: managedObjectContext,
                                                sectionNameKeyPath: nil, cacheName: nil)

        publisher = detector
            .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()

        super.init()
        controller.delegate = self

//        PersistenceController.shared.container.viewContext.perform {
//            let list = ReminderListItem(context: PersistenceController.shared.container.viewContext)
//            list.name = "My First List"
//
//            let reminder = ReminderItem(context: PersistenceController.shared.container.viewContext)
//            reminder.title = "Title"
//            reminder.notes = "Notes Here"
//            reminder.dateCreated = Date()
//            reminder.date = Date()
//            reminder.priority = 0
//            reminder.list = list
//
//            PersistenceController.shared.save()
//        }
    }

    func fetchList() {
        print("Fetching reminder list")
        do {
            try controller.performFetch()
            list = controller.fetchedObjects ?? []

//            for i in list {
//                for j in i.reminders ?? [] {
//                    print((j as? ReminderItem)?.title)
//                }
//            }
//
//            PersistenceController.shared.save()

            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }
                if self.selection != nil, self.selection != self.defaultSelection {
                    var needReset = true
                    for item in self.list {
                        if item.id == self.selection {
                            needReset = false
                        }
                    }

                    if needReset {
                        DispatchQueue.main.async {
                            self.selection = self.defaultSelection
                        }
                    }
                }
            }
        } catch {
            print("failed to fetch items!")
        }
    }

    func createList(name: String) {
        PersistenceController.shared.container.viewContext.perform {
            let newItem = ReminderListItem(context: PersistenceController.shared.container.viewContext)
            newItem.name = name
            PersistenceController.shared.save()
        }
    }

    func deleteList(name: String) {
        for i in list {
            if i.name == name {
                PersistenceController.shared.container.viewContext.perform {
                    PersistenceController.shared.container.viewContext.delete(i)
                    PersistenceController.shared.save()
                }
                break
            }
        }
    }

    func editReminder(item: ReminderItem, title: String, notes: String, date: Date?, priority: Int16, completed: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            let password = ValetController.getPassword()
            let newTitle = EncryptionHelper.encryptString(input: title, withPassword: password.0)
            let newNotes = EncryptionHelper.encryptString(input: notes, withPassword: password.0)

            PersistenceController.shared.container.viewContext.perform {
                if let newTitle = newTitle, let newNotes = newNotes {
                    item.title = newTitle
                    item.notes = newNotes
                    item.date = date
                    item.priority = priority
                    item.completed = NSNumber(booleanLiteral: completed)
                    PersistenceController.shared.save()
                } else {
                    print("Encrypt failed!!!")
                }
            }
        }
    }

    func addReminder(list: ReminderListItem) {
        DispatchQueue.global(qos: .userInitiated).async {
            let password = ValetController.getPassword()
            let emptyString = EncryptionHelper.encryptString(input: "", withPassword: password.0)

            PersistenceController.shared.container.viewContext.perform {
                let reminder = ReminderItem(context: PersistenceController.shared.container.viewContext)
                reminder.title = emptyString
                reminder.notes = emptyString
                reminder.dateCreated = Date()
                reminder.date = nil
                reminder.priority = 0
                reminder.completed = NSNumber(booleanLiteral: false)
                list.addToReminders(reminder)

                self.focus = reminder.id

                PersistenceController.shared.save()
            }
        }
    }
}

extension ReminderItemStorage: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        fetchList()
    }
}
