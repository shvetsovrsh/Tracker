//
// Created by Ruslan S. Shvetsov on 06.01.2024.
//

import UIKit
import CoreData

final class TrackerConversionService {

    static func convertToTrackerCoreData(_ tracker: Tracker, context: NSManagedObjectContext) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.isHabit = tracker.isHabit
        trackerCoreData.isPinned = tracker.isPinned
        trackerCoreData.completedDays = Int16(tracker.completedDays)
        trackerCoreData.previousCategory = tracker.previousCategory
        return trackerCoreData
    }

    static func convertToTracker(_ trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id,
              let name = trackerCoreData.name,
              let color = trackerCoreData.color as? UIColor,
              let emoji = trackerCoreData.emoji,
              let schedule = trackerCoreData.schedule as? [DayOfWeek]
        else {
            throw TrackerError.conversionFailed
        }
        let isHabit = trackerCoreData.isHabit
        let isPinned = trackerCoreData.isPinned
        let completedDays = Int(trackerCoreData.completedDays)
        let previousCategory = trackerCoreData.previousCategory

        return Tracker(id: id,
                name: name,
                color: color,
                emoji: emoji,
                schedule: schedule,
                isHabit: isHabit,
                isPinned: isPinned,
                completedDays: completedDays,
                previousCategory: previousCategory
        )
    }
}
