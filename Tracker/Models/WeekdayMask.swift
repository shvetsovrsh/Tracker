//
// Created by Ruslan S. Shvetsov on 04.01.2024.
//

import Foundation

struct WeekdayMask: OptionSet {
    let rawValue: Int

    static let monday = WeekdayMask(rawValue: 1 << 0)
    static let tuesday = WeekdayMask(rawValue: 1 << 1)
    static let wednesday = WeekdayMask(rawValue: 1 << 2)
    static let thursday = WeekdayMask(rawValue: 1 << 3)
    static let friday = WeekdayMask(rawValue: 1 << 4)
    static let saturday = WeekdayMask(rawValue: 1 << 5)
    static let sunday = WeekdayMask(rawValue: 1 << 6)

    static let allDays: WeekdayMask = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
}
