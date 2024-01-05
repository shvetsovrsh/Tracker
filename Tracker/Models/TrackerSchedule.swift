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
