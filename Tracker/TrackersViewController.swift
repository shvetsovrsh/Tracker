//
// Created by Ruslan S. Shvetsov on 01.09.2023.
//

import Foundation

final class TrackersViewController {
    var categories: [TrackerCategory]
    var visibleCategories: [TrackerCategory]
    var completedTrackers: [TrackerRecord]
    var currentDate: Date

    init(categories: [TrackerCategory], visibleCategories: [TrackerCategory], completedTrackers: [TrackerRecord], currentDate: Date) {
        self.categories = categories
        self.visibleCategories = visibleCategories
        self.completedTrackers = completedTrackers
        self.currentDate = currentDate
    }
}