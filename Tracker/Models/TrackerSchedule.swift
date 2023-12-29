//
// Created by Ruslan S. Shvetsov on 01.09.2023.
//

import Foundation

public struct TrackerSchedule {
    let frequency: TrackerFrequency
    let daysOfWeek: [DayOfWeek]
    let specificDays: [Date]

    init(frequency: TrackerFrequency, daysOfWeek: [DayOfWeek], specificDays: [Date]) {
        self.frequency = frequency
        self.daysOfWeek = daysOfWeek
        self.specificDays = specificDays
    }
}

enum TrackerFrequency {
    case daily
    case weekly
}

enum DayOfWeek: String {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
}
