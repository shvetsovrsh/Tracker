//
// Created by Ruslan S. Shvetsov on 09.01.2024.
//

import Foundation

@propertyWrapper
struct UserDefaultsBacked<Value> {
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = .standard

    var wrappedValue: Value {
        get { storage.object(forKey: key) as? Value ?? defaultValue }
        set { storage.set(newValue, forKey: key) }
    }
}


extension UserDefaults {
    @UserDefaultsBacked(key: "hasSeenOnboarding", defaultValue: false)
    static var hasSeenOnboarding: Bool
}
