//
// Created by Ruslan S. Shvetsov on 27.12.2023.
//
import UIKit

final class InsetTextField: UITextField {

    let textInsets: UIEdgeInsets

    init(textInsets: UIEdgeInsets) {
        self.textInsets = textInsets
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }
}

