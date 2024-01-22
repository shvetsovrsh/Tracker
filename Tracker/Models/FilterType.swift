//
// Created by Ruslan S. Shvetsov on 20.01.2024.
//

import Foundation

enum FilterType: Int {
    case all = 0
    case today
    case completed
    case notCompleted

    var name: String {
        switch self {
        case .all:
            return "Все трекеры"
        case .today:
            return "Трекеры на сегодня"
        case .completed:
            return "Завершённые"
        case .notCompleted:
            return "Незавершённые"
        }
    }
}
