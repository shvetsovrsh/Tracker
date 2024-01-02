//
// Created by Ruslan S. Shvetsov on 27.12.2023.
//

import UIKit

final class EventCreationViewController: UIViewController {

    weak var delegate: TrackerCreationViewControllerDelegate?
    weak var delegateDidClose: TrackerCreationViewControllerDidCloseDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(createButton)
        view.backgroundColor = UIColor(named: "YPDefaultWhite")
    }

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = UIColor(named: "YPWhite")
        button.backgroundColor = UIColor(named: "YPGray")
        button.setTitle("Cоздать", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(nil, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc private func createButtonTapped() {
        if let delegate = delegate {
            delegate.addNewTracker(
                    TrackerCategory(title: "", trackers: [Tracker(id: UUID(),
                            name: "", color: UIColor(named: "YPColorSelection1") ?? .blue,
                            emoji: "😻️",
                            schedule: TrackerSchedule(frequency: .daily,
                                    daysOfWeek: [],
                                    specificDays: []))])
            )
            delegateDidClose?.trackerCreationViewControllerDidClose(self)
        }
        dismiss(animated: true)
    }
}
