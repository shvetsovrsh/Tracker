//
// Created by Ruslan S. Shvetsov on 18.12.2023.
//

import UIKit


final class TrackerCreationViewController: UIViewController,
        TrackerCreationViewControllerDidCloseDelegate {

    weak var delegate: TrackerCreationViewControllerDelegate?

    init(delegate: TrackerCreationViewControllerDelegate?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var habitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "YPBlack")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var eventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "YPBlack")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(eventButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private func addElements() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(habitButton)
        stackView.addArrangedSubview(eventButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addElements()
        setupView()

        view.backgroundColor = UIColor(named: "YPDefaultWhite")
    }

    private func setupView() {
        navigationItem.title = "Создание трекера"

        NSLayoutConstraint.activate([

            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            habitButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    @objc private func habitButtonTapped() {
        let viewController = HabitCreationViewController()
        viewController.delegate = delegate
        viewController.delegateDidClose = self
        present(viewController, animated: true)
    }

    @objc private func eventButtonTapped() {
        let viewController = EventCreationViewController()
        viewController.delegate = delegate
        viewController.delegateDidClose = self
        present(viewController, animated: true)
    }

    func trackerCreationViewControllerDidClose(_ viewController: UIViewController) {
        viewController.dismiss(animated: true)
        dismiss(animated: true)
    }
}
