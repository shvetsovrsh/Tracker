//
// Created by Ruslan S. Shvetsov on 21.01.2024.
//

import Foundation
import YandexMobileMetrica

final class AnalyticsService {

    static let shared = AnalyticsService()

    private init() {}

    func reportEvent(screen: String, item: AnalyticsItem = .none, event: AnalyticsEvent) {
        var parameters: [String: String] = ["screen": screen]
        // ignore open & close events
        if item != .none {
            parameters["item"] = item.rawValue
        }
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: parameters, onFailure: { error in
            print("Error sending event: \(error.localizedDescription)")
        })
    }
}