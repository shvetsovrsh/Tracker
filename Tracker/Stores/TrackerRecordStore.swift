//
// Created by Ruslan S. Shvetsov on 06.01.2024.
//

import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    static let shared = TrackerRecordStore()
    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

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
            print("Failed to fetch records: \(error)")
        }
    }
}


extension TrackerRecordStore {
    func numberOfSections() -> Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRows(in section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func record(at indexPath: IndexPath) -> TrackerRecord? {
        let recordCoreData = fetchedResultsController.object(at: indexPath)
        return try? convertToTrackerRecord(recordCoreData)
    }

    var records: [TrackerRecord] {
        guard let recordsCoreData = fetchedResultsController.fetchedObjects else {
            return []
        }

        return recordsCoreData.compactMap { recordCoreData in
            try? convertToTrackerRecord(recordCoreData)
        }
    }

    private func convertToTrackerRecord(_ recordCoreData: TrackerRecordCoreData) throws -> TrackerRecord? {
        guard let trackerID = recordCoreData.trackerID,
              let date = recordCoreData.date
        else {
            throw TrackerError.notFound
        }

        return TrackerRecord(trackerID: trackerID, date: date)
    }
}


extension TrackerRecordStore {
    func addRecord(for trackerID: UUID, date: Date) {
        let record = TrackerRecordCoreData(context: context)

        let trackerFetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerFetchRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)

        if let trackerCoreData = (try? context.fetch(trackerFetchRequest))?.first {
            record.tracker = trackerCoreData
            record.trackerID = trackerID
            record.date = date

            saveContext()
        }
    }

    func removeRecord(for trackerID: UUID, date: Date) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@ AND date == %@", trackerID as CVarArg, date as NSDate)

        if let result = try? context.fetch(fetchRequest), let recordToDelete = result.first {
            context.delete(recordToDelete)
            saveContext()
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


extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Код для подготовки к изменениям в контенте (например, начало обновления таблицы)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Код для реагирования на изменения в контенте (например, завершение обновления таблицы)
    }

    // Другие методы делегата для обработки конкретных изменений
}
