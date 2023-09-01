//
// Created by Ruslan S. Shvetsov on 01.09.2023.
//

import Foundation

public struct TrackerRecord {
    let trackerID: UUID
    let date: Date

    init(trackerID: UUID, date: Date) {
        self.trackerID = trackerID
        self.date = date
    }
}