//
// Created by Ruslan S. Shvetsov on 20.01.2024.
//

import Foundation

final class FilterData {
    static let shared = FilterData()

    private let filters = [FilterType.all, FilterType.today, FilterType.completed, FilterType.notCompleted]

    func getSize() -> Int {
        filters.count
    }

    func getFilter(at index: Int) -> FilterType? {
        filters[index]
    }

    func getFilter(at indexPath: IndexPath) -> FilterType? {
        guard indexPath.row < filters.count else {
            return nil
        }
        return filters[indexPath.row]
    }
}
