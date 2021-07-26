//
//  NoteItemStorage.swift
//  Privacy Suite
//
//  Created by Kevin Guan on 7/20/21.
//

import Combine
import CoreData
import Foundation

class NoteItemStorage: NSObject, ObservableObject {
    @Published var notes: [NoteItem] = []
    @Published var selection: ObjectIdentifier?
    var defaultSelection = ObjectIdentifier(Dummy())
    var shouldAutoSave = false

    let detector = PassthroughSubject<Void, Never>()
    let publisher: AnyPublisher<Void, Never>

    private let controller: NSFetchedResultsController<NoteItem>

    init(managedObjectContext: NSManagedObjectContext) {
        print("Storage INITING")
        controller = NSFetchedResultsController(fetchRequest: NoteItem.getFetchRequest,
                                                managedObjectContext: managedObjectContext,
                                                sectionNameKeyPath: nil, cacheName: nil)
        publisher = detector
            .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()

        super.init()
        controller.delegate = self
    }

    func fetchNotes() {
        print("fetchNotes")

        do {
            try controller.performFetch()
            notes = controller.fetchedObjects ?? []

            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }
                if self.selection != nil, self.selection != self.defaultSelection {
                    var needReset = true
                    for note in self.notes {
                        if note.id == self.selection {
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

    func edit(item: NoteItem, title: String, content: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let password = ValetController.getPassword()
            let newTitle = EncryptionHelper.encryptString(input: title, withPassword: password.0)
            let newContent = EncryptionHelper.encryptString(input: content, withPassword: password.0)

            PersistenceController.shared.container.viewContext.perform {
                if let newTitle = newTitle, let newContent = newContent {
                    item.title = newTitle
                    item.content = newContent
                    item.lastEdited = Date()
                    PersistenceController.shared.save()
                } else {
                    print("Encrypt failed!!!")
                }
            }
        }
    }

    func add(title: String, content: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let password = ValetController.getPassword()
            let title = EncryptionHelper.encryptString(input: title, withPassword: password.0)
            let content = EncryptionHelper.encryptString(input: content, withPassword: password.0)

            PersistenceController.shared.container.viewContext.perform {
                let newItem = NoteItem(context: PersistenceController.shared.container.viewContext)
                if let title = title, let content = content {
                    newItem.title = title
                    newItem.content = content
                    newItem.lastEdited = Date()
                    newItem.dateCreated = Date()
                    PersistenceController.shared.save()

                    self.selection = newItem.id
                } else {
                    print("Encrypt failed!!!")
                }
            }
        }
    }

    func delete(by offsets: IndexSet) {
        if let index = offsets.first {
            PersistenceController.shared.container.viewContext.perform {
                PersistenceController.shared.container.viewContext.delete(self.notes[index])
                PersistenceController.shared.save()
            }
        }
    }

    func delete(by item: NoteItem) {
        PersistenceController.shared.container.viewContext.perform {
            PersistenceController.shared.container.viewContext.delete(item)
            PersistenceController.shared.save()
        }
    }
}

extension NoteItemStorage: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        fetchNotes()
    }
}

class Dummy {}
