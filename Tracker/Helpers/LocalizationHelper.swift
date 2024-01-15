//
// Created by Ruslan S. Shvetsov on 15.01.2024.
//

import Foundation
//TODO
final class LocalizationHelper {
    static func pluralizeDays(for days: Int) -> String {
        let remainder = days % 10
        if days == 11 || days == 12 || days == 13 || days == 14 {
            return "\(days) дней"
        }
        switch remainder {
        case 1:
            return "\(days) день"
        case 2, 3, 4:
            return "\(days) дня"
        default:
            return "\(days) дней"
        }
    }
}