//
//  ReminderItemStorage.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/22/21.
//

import CoreData
import Foundation

class ReminderItemStorage: NSObject, ObservableObject {
    @Published var list: [ReminderListItem] = []
    @Published var selection: ObjectIdentifier?
    var defaultSelection = ObjectIdentifier(Dummy())

    private let controller: NSFetchedResultsController<ReminderListItem>

    init(managedObjectContext: NSManagedObjectContext) {
        print("Storage INITING")
        controller = NSFetchedResultsController(fetchRequest: ReminderListItem.getFetchRequest,
                                                managedObjectContext: managedObjectContext,
                                                sectionNameKeyPath: nil, cacheName: nil)

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
}

extension ReminderItemStorage: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        fetchList()
    }
}
