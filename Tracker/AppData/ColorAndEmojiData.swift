//
// Created by Ruslan S. Shvetsov on 15.10.2023.
//

import UIKit

struct CollectionDataSource: SelectableCollectionDataSource {
    var items: [Any]
    var title: String

    init(items: [Any], title: String) {
        self.items = items
        self.title = title
    }
}

final class ColorAndEmojiData {
    static let shared = ColorAndEmojiData()

    var emojiData: CollectionDataSource
    var colorData: CollectionDataSource

    private let emojis: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                                    "😇", "😡", "🥶", "🤔", "🙌", "🍔",
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
    }
}
