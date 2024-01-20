//
// Created by Ruslan S. Shvetsov on 05.01.2024.
//

import CoreData
import UIKit

final class TrackerStore: NSObject {
    static let shared = TrackerStore()
    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                managedObjectContext: self.context,
                sectionNameKeyPath: nil,
                cacheName: nil)
        controller.delegate = self
        return controller
    }()

    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Failed to retrieve core data manager")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch entities: \(error)")
        }
    }
}


extension TrackerStore {
    func numberOfSections() -> Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRows(in section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tracker(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return try? TrackerConversionService.convertToTracker(trackerCoreData)
    }
}

extension TrackerStore {
    func updateIsPinned(for trackerId: UUID, isPinned: Bool) {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)

        do {
            let results = try context.fetch(request)
            if let trackerToUpdate = results.first {
                trackerToUpdate.isPinned = isPinned
                if isPinned {
                    trackerToUpdate.previousCategory = trackerToUpdate.category?.title
                } else {
                    trackerToUpdate.category?.title = trackerToUpdate.previousCategory
                }
                saveContext()
            }
        } catch {
            print("Error updating isPinned: \(error)")
        }
    }

    func changeCompletedDays(for trackerId: UUID, increment: Bool) {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)

        do {
            let results = try context.fetch(request)
            if let trackerToUpdate = results.first {
                if increment {
                    trackerToUpdate.completedDays += 1
                } else if trackerToUpdate.completedDays > 0 {
                    trackerToUpdate.completedDays -= 1
                }
                saveContext()
            }
        } catch {
            print("Error changing completedDays: \(error)")
        }
    }

    func updateTracker(for tracker: Tracker, withTitle title: String, completionHandler: @escaping () -> Void) {
        let trackerRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)

        let categoryRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "title == %@", title)

        do {
            let trackerResults = try context.fetch(trackerRequest)
            let categoryResults = try context.fetch(categoryRequest)

            if let trackerToUpdate = trackerResults.first {
                trackerToUpdate.name = tracker.name
                trackerToUpdate.color = tracker.color
                trackerToUpdate.emoji = tracker.emoji
                trackerToUpdate.schedule = tracker.schedule as NSObject
                trackerToUpdate.isHabit = tracker.isHabit
                trackerToUpdate.isPinned = tracker.isPinned
                trackerToUpdate.completedDays = Int16(tracker.completedDays)
                trackerToUpdate.previousCategory = tracker.previousCategory

                if let existingCategory = categoryResults.first {
                    trackerToUpdate.category = existingCategory
                } else {
                    let newCategory = TrackerCategoryCoreData(context: context)
                    newCategory.title = title
                    trackerToUpdate.category = newCategory
                }

                try context.save()
            }

            DispatchQueue.main.async {
                completionHandler()
            }

        } catch {
            print("Error updating tracker: \(error)")
        }
    }

    func removeTracker(for trackerID: UUID) {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)

        do {
            let results = try context.fetch(request)
            if let trackerToDelete = results.first {
                if let trackerRecords = trackerToDelete.records as? Set<TrackerRecordCoreData> {
                    for record in trackerRecords {
                        context.delete(record)
                    }
                }
                context.delete(trackerToDelete)
                try context.save()
            }
        } catch {
            print("Error removing tracker: \(error)")
        }
    }

    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}


extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Код для подготовки к изменениям в контенте (например, начало обновления таблицы)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Код для реагирования на изменения в контенте (например, завершение обновления таблицы)
    }

    // Другие методы делегата для обработки конкретных изменений
}
