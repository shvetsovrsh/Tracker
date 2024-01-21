//
// Created by Ruslan S. Shvetsov on 09.01.2024.
//

import UIKit

final class OnboardingView: UIView {

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(named: "YPBlack")
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
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
        addSubview(imageView)
        addSubview(textLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 432),
            textLabel.widthAnchor.constraint(equalToConstant: 343)
        ])
    }

    func configure(with image: UIImage?, text: String?) {
        imageView.image = image
        textLabel.text = text
    }
}
