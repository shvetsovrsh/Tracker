//
// Created by Ruslan S. Shvetsov on 12.12.2023.
//

import UIKit

protocol TrackersViewControllerDelegate: AnyObject {
    func updateCollectionView()
    func updateButtonStateFromDate() -> Date
    func updateCompletedTrackers(tracker: Tracker, at indexPath: IndexPath)
}

final class TrackerCell: UICollectionViewCell {

    weak var delegate: TrackersViewControllerDelegate?
    private var tracker: Tracker?
    private var isCompletedToday: Bool = false
    private var indexPath: IndexPath?

    private let cardBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "YPDefaultWhite")
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private var statisticLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(named: "YPBlack")
        label.text = "0 дней"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()

    private let completionButton: UIButton = {
        let button = UIButton(type: .system)
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11)
        let image = UIImage(systemName: "plus", withConfiguration: pointSize)
        button.tintColor = .white
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(trackButtonTapped), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(cardBackgroundView)

        cardBackgroundView.addSubview(titleLabel)
        cardBackgroundView.addSubview(emojiLabel)

        contentView.addSubview(statisticLabel)
        contentView.addSubview(completionButton)

        NSLayoutConstraint.activate([
            cardBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardBackgroundView.heightAnchor.constraint(equalToConstant: 90),

            emojiLabel.topAnchor.constraint(equalTo: cardBackgroundView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardBackgroundView.leadingAnchor, constant: 12),

            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: cardBackgroundView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardBackgroundView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: cardBackgroundView.bottomAnchor, constant: -12),

            titleLabel.widthAnchor.constraint(equalToConstant: 143),
            titleLabel.heightAnchor.constraint(equalToConstant: 34),

            statisticLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            statisticLabel.topAnchor.constraint(equalTo: cardBackgroundView.bottomAnchor, constant: 16),
            statisticLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            completionButton.topAnchor.constraint(equalTo: cardBackgroundView.bottomAnchor, constant: 8),
            completionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            completionButton.trailingAnchor.constraint(equalTo: cardBackgroundView.trailingAnchor, constant: -12),
            completionButton.widthAnchor.constraint(equalToConstant: 34),
            completionButton.heightAnchor.constraint(equalToConstant: 34),

        ])
    }

    private let plusImage: UIImage = {
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11)
        let image = UIImage(systemName: "plus", withConfiguration: pointSize) ?? UIImage()
        return image
    }()

    private let doneImage: UIImage = {
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11)
        let image = UIImage(systemName: "checkmark", withConfiguration: pointSize) ?? UIImage()
        return image
    }()

    func configure(for cell: TrackerCell,
                   tracker: Tracker,
                   title: String,
                   color: UIColor,
                   emoji: String,
                   indexPath: IndexPath,
                   completedDays: Int,
                   isCompletedToday: Bool
    ) {
        self.tracker = tracker
        titleLabel.text = title
        emojiLabel.text = emoji
        statisticLabel.text = LocalizationHelper.pluralizeDays(for: completedDays)
        cardBackgroundView.backgroundColor = color
        completionButton.backgroundColor = color
        self.indexPath = indexPath
        self.isCompletedToday = isCompletedToday

        let image = isCompletedToday ? doneImage : plusImage
        completionButton.setImage(image, for: .normal)
        completionButton.alpha = isCompletedToday ? 0.3 : 1.0
    }

    @objc private func trackButtonTapped() {
        guard let tracker = tracker, let indexPath = indexPath else {
            assertionFailure("no trackers")
            return
        }
        delegate?.updateCompletedTrackers(tracker: tracker, at: indexPath)
    }
}
