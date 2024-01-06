//
// Created by Ruslan S. Shvetsov on 06.01.2024.
//

import CoreData

final class TrackerRecordStore: NSObject {
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

    private func convertToTrackerRecord(_ recordCoreData: TrackerRecordCoreData) throws -> TrackerRecord? {
        guard let trackerID = recordCoreData.trackerID,
              let date = recordCoreData.date
        else {
            throw TrackerError.notFound
        }

        return TrackerRecord(trackerID: trackerID, date: date)
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
