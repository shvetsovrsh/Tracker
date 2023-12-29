//
// Created by Ruslan S. Shvetsov on 15.10.2023.
//

import Foundation
import UIKit

final class MockData {
    static let shared = MockData()

    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []

    private init() {
        let trackersCategory1 = TrackerCategory(
                title: "Домашний уют",
                trackers: [
                    Tracker(id: UUID(), name: "Поливать растения", color: .green, emoji: "❤️", schedule: TrackerSchedule(frequency: .daily, daysOfWeek: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday], specificDays: []))
                ]
        )

        let trackersCategory2 = TrackerCategory(
                title: "Радостные мелочи",
                trackers: [
                    Tracker(id: UUID(), name: "Кошка заслонила камеру на созвоне", color: .orange, emoji: "😻", schedule: TrackerSchedule(frequency: .daily, daysOfWeek: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday], specificDays: [])),
                    Tracker(id: UUID(), name: "Бабушка прислала открытку в вотсапе", color: .red, emoji: "🌺", schedule: TrackerSchedule(frequency: .daily, daysOfWeek: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday], specificDays: [])),
                    Tracker(id: UUID(), name: "Свидания в апреле", color: .blue, emoji: "❤️", schedule: TrackerSchedule(frequency: .daily, daysOfWeek: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday], specificDays: []))
                ]
        )

        categories.append(contentsOf: [trackersCategory1, trackersCategory2])


        if let tracker1 = trackersCategory1.trackers.first?.id, let tracker2 = trackersCategory2.trackers.first?.id {
            completedTrackers.append(TrackerRecord(trackerID: tracker1, date: Date()))
            completedTrackers.append(TrackerRecord(trackerID: tracker2, date: Date()))
        }
    }
}
