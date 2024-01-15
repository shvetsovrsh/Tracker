//
// Created by Ruslan S. Shvetsov on 01.09.2023.
//

import Foundation
import UIKit
//TODO !!!!!
public struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [DayOfWeek]
//    let isHabit: Bool
//    let isPinned: Bool
//    let completedDays: Int

//    init(id: UUID,
//          name: String,
//          color: UIColor,
//          emoji: String,
//          schedule: [DayOfWeek],
//          isHabit: Bool,
//          isPinned: Bool,
//          completedDays: Int) {
    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: [DayOfWeek]) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
//        self.isHabit = isHabit
//        self.isPinned = isPinned
//        self.completedDays = completedDays
    }
}
