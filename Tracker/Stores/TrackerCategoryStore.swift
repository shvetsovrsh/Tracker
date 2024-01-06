//
// Created by Ruslan S. Shvetsov on 06.01.2024.
//

import CoreData
import UIKit

final class TrackerCategoryStore: NSObject {
    static let shared = TrackerCategoryStore()
    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

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
            print("Failed to fetch categories: \(error)")
        }
    }
}


extension TrackerCategoryStore {
    func numberOfSections() -> Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfRows(in section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func category(at indexPath: IndexPath) -> TrackerCategory? {
        let categoryCoreData = fetchedResultsController.object(at: indexPath)
        return try? convertToTrackerCategory(categoryCoreData)
    }
}

extension TrackerCategoryStore {
    private func convertToTrackerCategory(_ categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory? {
        guard let title = categoryCoreData.title else {
            throw TrackerError.notFound
        }

        let trackers = (categoryCoreData.trackers?.allObjects as? [TrackerCoreData])?.compactMap {
            try? TrackerConversionService.convertToTracker($0)
        } ?? []

        return TrackerCategory(title: title, trackers: trackers)
    }

    var categories: [TrackerCategory] {
        guard let categoriesCoreData = fetchedResultsController.fetchedObjects else {
            return []
        }

        return categoriesCoreData.compactMap { categoryCoreData in
            try? convertToTrackerCategory(categoryCoreData)
        }
    }
}


extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Код для подготовки к изменениям в контенте (например, начало обновления таблицы)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Код для реагирования на изменения в контенте (например, завершение обновления таблицы)
    }

    // Другие методы делегата для обработки конкретных изменений
}
