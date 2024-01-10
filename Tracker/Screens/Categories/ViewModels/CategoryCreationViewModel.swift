//
// Created by Ruslan S. Shvetsov on 10.01.2024.
//

import Foundation

protocol CategoryStorable {
    var categories: [TrackerCategory] { get }
    func numberOfSections() -> Int
    func numberOfRows(in section: Int) -> Int
    func category(at indexPath: IndexPath) -> TrackerCategory?
    func isEmpty() -> Bool
    func addNewCategory(toCategoryWithTitle title: String, completionHandler: @escaping () -> Void)
}

final class CategoryCreationViewModel {
    private let categoryStore: CategoryStorable

    var categories: [TrackerCategory] {
        categoryStore.categories
    }

    init(categoryStore: CategoryStorable) {
        self.categoryStore = categoryStore
    }

    func isEmpty() -> Bool {
        categoryStore.isEmpty()
    }

    func numberOfSections() -> Int {
       categoryStore.numberOfSections()
    }

    func numberOfRows(in section: Int) -> Int {
        categoryStore.numberOfRows(in: section)
    }

    func category(at indexPath: IndexPath) -> TrackerCategory? {
        categoryStore.category(at: indexPath)
    }

    func addCategory(withTitle title: String, completionHandler: @escaping () -> Void) {
        guard !title.isEmpty else {
            completionHandler()
            return
        }

        categoryStore.addNewCategory(toCategoryWithTitle: title) {
            completionHandler()
        }
    }

    func selectCategory(at index: Int) -> TrackerCategory? {
        guard index >= 0, index < categories.count else {
            return nil
        }
        return categories[index]
    }

}