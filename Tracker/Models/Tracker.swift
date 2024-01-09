//
// Created by Ruslan S. Shvetsov on 01.09.2023.
//

import Foundation
import UIKit

public struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [DayOfWeek]

    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: [DayOfWeek]) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}
