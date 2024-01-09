//
// Created by Ruslan S. Shvetsov on 15.10.2023.
//

import Foundation
import UIKit

//TODO remove this file on next iterations

final class MockData {
    static let shared = MockData()

    struct CollectionDataSource: SelectableCollectionDataSource {
        var items: [Any]
        var title: String

        init(items: [Any], title: String) {
            self.items = items
            self.title = title
        }
    }

    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var emojiData: CollectionDataSource
    var colorData: CollectionDataSource

    private let emojis: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                                    "😇", "😇", "🥶", "🤔", "🙌", "🍔",
                                    "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]

    private let colors: [UIColor] = {
        var colors: [UIColor] = []
        for idx in 1...18 {
            let colorName = "YPColorSelection\(idx)"
            if let color = UIColor(named: colorName) {
                colors.append(color)
            }
        }
        return colors
    }()

    private init() {
        emojiData = CollectionDataSource(items: emojis, title: "Emoji")
        colorData = CollectionDataSource(items: colors, title: "Цвет")

        let trackersCategory1 = TrackerCategory(
                title: "Домашний уют",
                trackers: [
                    Tracker(id: UUID(), name: "Поливать растения",
                            color: UIColor(named: "YPColorSelection5") ?? UIColor.gray, emoji: "❤️",
                            schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
                    )
                ]
        )

        let trackersCategory2 = TrackerCategory(
                title: "Радостные мелочи",
                trackers: [
                    Tracker(id: UUID(), name: "Кошка заслонила камеру на созвоне",
                            color: UIColor(named: "YPColorSelection2") ?? UIColor.gray, emoji: "😻",
                            schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]),
                    Tracker(id: UUID(), name: "Бабушка прислала открытку в вотсапе",
                            color: UIColor(named: "YPColorSelection1") ?? UIColor.gray, emoji: "🌺",
                            schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]),
                    Tracker(id: UUID(), name: "Свидания в апреле",
                            color: UIColor(named: "YPColorSelection14") ?? UIColor.gray, emoji: "❤️",
                            schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday])
                ]
        )

        categories.append(contentsOf: [trackersCategory1, trackersCategory2])

        if let tracker1 = trackersCategory1.trackers.first?.id, let tracker2 = trackersCategory2.trackers.first?.id {
            completedTrackers.append(TrackerRecord(trackerID: tracker1, date: Date()))
            completedTrackers.append(TrackerRecord(trackerID: tracker2, date: Date()))
        }
    }
}
