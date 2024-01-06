//
// Created by Ruslan S. Shvetsov on 06.01.2024.
//

import UIKit

final class TrackerConversionService {

    static func convertToTracker(_ trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id,
              let name = trackerCoreData.name,
              let color = trackerCoreData.color as? UIColor,
              let emoji = trackerCoreData.emoji,
              let schedule = trackerCoreData.schedule as? [DayOfWeek]
        else {
            throw TrackerError.conversionFailed
        }

        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
}
