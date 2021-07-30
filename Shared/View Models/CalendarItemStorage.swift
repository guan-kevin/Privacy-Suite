//
//  CalendarItemStorage.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/29/21.
//

import Combine
import CoreData
import Foundation

class CalendarItemStorage: NSObject, ObservableObject {
    @Published var list: [CalendarListItem] = []

    @Published var selection: ObjectIdentifier?
    var defaultSelection = ObjectIdentifier(Dummy())

    private let controller: NSFetchedResultsController<CalendarListItem>

    var focus: ObjectIdentifier?
    let detector = PassthroughSubject<Void, Never>()
    let publisher: AnyPublisher<Void, Never>

    init(managedObjectContext: NSManagedObjectContext) {
        print("Storage INITING")
        controller = NSFetchedResultsController(fetchRequest: CalendarListItem.getFetchRequest,
                                                managedObjectContext: managedObjectContext,
                                                sectionNameKeyPath: nil, cacheName: nil)

        publisher = detector
            .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()

        super.init()
        controller.delegate = self
    }

    func fetchList() {
        print("Fetching Calendar List")
        do {
            try controller.performFetch()
            list = controller.fetchedObjects ?? []

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
            let newItem = CalendarListItem(context: PersistenceController.shared.container.viewContext)
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

extension CalendarItemStorage: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        fetchList()
    }
}
