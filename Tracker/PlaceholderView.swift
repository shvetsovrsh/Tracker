//
// Created by Ruslan S. Shvetsov on 25.10.2023.
//

import UIKit

final class PlaceholderView: UIView {
    private let imagePlaceholder: UIImageView = {
        let imagePlaceholder = UIImageView()
        imagePlaceholder.translatesAutoresizingMaskIntoConstraints = false
        return imagePlaceholder
    }()

    private let textPlaceholder: UILabel = {
        let textPlaceholder = UILabel()
        textPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        textPlaceholder.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        textPlaceholder.textColor = UIColor(named: "YPBlack")
        return textPlaceholder
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        translatesAutoresizingMaskIntoConstraints = false
    }
    

    private func setupView() {
        addSubview(imagePlaceholder)
        addSubview(textPlaceholder)

        NSLayoutConstraint.activate([
            imagePlaceholder.centerXAnchor.constraint(equalTo: centerXAnchor),
            imagePlaceholder.topAnchor.constraint(equalTo: topAnchor)
        ])

        NSLayoutConstraint.activate([
            textPlaceholder.centerXAnchor.constraint(equalTo: centerXAnchor),
            textPlaceholder.topAnchor.constraint(equalTo: imagePlaceholder.bottomAnchor, constant: 8)
        ])
    }

    func configure(with image: UIImage?, text: String?) {
        imagePlaceholder.image = image
        textPlaceholder.text = text
    }
}

