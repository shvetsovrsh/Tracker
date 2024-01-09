//
// Created by Ruslan S. Shvetsov on 06.01.2024.
//

import UIKit

@objc(UIColorValueTransformer)
class UIColorValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else {
            return nil
        }
        return try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else {
            return nil
        }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data as Data)
    }

    static func register() {
        ValueTransformer.setValueTransformer(
                UIColorValueTransformer(),
                forName: NSValueTransformerName(rawValue: String(describing: UIColorValueTransformer.self))
        )
    }
}
