//
// Created by Ruslan S. Shvetsov on 15.01.2024.
//

import Foundation


final class LocalizationHelper {
    static func pluralizeDays(for days: Int) -> String {
        let remainder = days % 10
        if days == 11 || days == 12 || days == 13 || days == 14 {
            let localized = String.localizedStringWithFormat(
                    NSLocalizedString("LocalizationHelper.days_11_14", comment: ""), days)
            return "\(days) \(localized)"
        }
        switch remainder {
        case 1:
            let localized = String.localizedStringWithFormat(
                    NSLocalizedString("LocalizationHelper.days_1", comment: ""), days)
            return "\(days) \(localized)"
        case 2, 3, 4:
            let localized = String.localizedStringWithFormat(
                    NSLocalizedString("LocalizationHelper.days_2_4", comment: ""), days)
            return "\(days) \(localized)"
        default:
            let localized = String.localizedStringWithFormat(
                    NSLocalizedString("LocalizationHelper.days_other", comment: ""), days)
            return "\(days) \(localized)"
        }
    }
}