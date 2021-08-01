//
//  CalendarItemStorage.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/29/21.
//

import Combine
import CoreData
import Foundation
#if os(iOS)
import UIKit
#endif

class CalendarItemStorage: NSObject, ObservableObject {
    @Published var list: [CalendarListItem] = []

    @Published var selection: ObjectIdentifier?
    var defaultSelection = ObjectIdentifier(Dummy())

    private let controller: NSFetchedResultsController<CalendarListItem>

    var focus: ObjectIdentifier?
    let detector = PassthroughSubject<Void, Never>()
    let publisher: AnyPublisher<Void, Never>

    @Published var isLandscape = false

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

        #if os(iOS)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(notification:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        checkOrientation()
        #endif
    }

    @objc func orientationChanged(notification: NSNotification) {
        checkOrientation()
    }

    func checkOrientation() {
        #if os(iOS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
                guard self.isLandscape == false else { return }
                self.isLandscape = true
            } else {
                guard self.isLandscape == true else { return }
                self.isLandscape = false
            }
        }
        #endif
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
