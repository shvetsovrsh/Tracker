//
// Created by Ruslan S. Shvetsov on 01.09.2023.
//

import Foundation

public struct TrackerCategory {
    let title: String
    var trackers: [Tracker]

    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
}
