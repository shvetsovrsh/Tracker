//
// Created by Ruslan S. Shvetsov on 27.12.2023.
//

import UIKit

protocol TrackerCreationViewControllerDelegate: AnyObject {
    func addNewTracker(_ trackerCategory: TrackerCategory)
}

protocol TrackerCreationViewControllerDidCloseDelegate: AnyObject {
    func trackerCreationViewControllerDidClose(_ viewController: UIViewController)
}


final class HabitCreationViewController: UIViewController,
        UITableViewDelegate, UITableViewDataSource,
        UITextFieldDelegate, ScheduleViewControllerDelegate {

    weak var delegate: TrackerCreationViewControllerDelegate?
    weak var delegateDidClose: TrackerCreationViewControllerDidCloseDelegate?

    private var tableViewTopConstraint: NSLayoutConstraint?
    private var tableViewTopConstraintWithCharLimit: NSLayoutConstraint?


    var daysOfWeek: [WeekDay] = []
    var daysOfWeekCasted: [DayOfWeek] = []
    private var category: String?

    let dayMapping: [WeekDay: DayOfWeek] = [
        .monday: .monday,
        .tuesday: .tuesday,
        .wednesday: .wednesday,
        .thursday: .thursday,
        .friday: .friday,
        .saturday: .saturday,
        .sunday: .sunday
    ]

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
//        view.contentSize = CGSize(width: view.bounds.width, height: 600)
        view.isMultipleTouchEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "YPBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameTextField: InsetTextField = {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 41)
        let field = InsetTextField(textInsets: insets)
        field.placeholder = "Введите название трекера"
        field.backgroundColor = UIColor(named: "YPBackground")
        field.clearButtonMode = .whileEditing
        field.textColor = UIColor(named: "YPGray")
        field.font = .systemFont(ofSize: 17, weight: .regular)
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 16
        field.translatesAutoresizingMaskIntoConstraints = false
        field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return field
    }()

    private let charLimitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(named: "YPColorSelection1")
        label.textAlignment = .center
        label.text = "Ограничение 38 символов"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    private let tableView = UITableView()

    private func setupTableView() {
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomTableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        } else if indexPath.row == 1 {
            cell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            category = "Важное" // TODO get rid of stub with mock data
            tableView.reloadData()
            updateCreateButtonState()
        } else if indexPath.row == 1 {
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            present(scheduleViewController, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        cell.backgroundColor = UIColor(named: "YPBackground")
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.subtitleLabel.text = category
            cell.subtitleLabel.textColor = UIColor.gray
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Расписание"

            if daysOfWeekCasted.count == 7 {
                cell.subtitleLabel.text = "Каждый день"
            } else {
                let selectedDays = daysOfWeekCasted.map { day in
                            mapDayOfWeekToString(day)
                        }
                        .joined(separator: ", ")

                cell.subtitleLabel.text = selectedDays
            }

            cell.subtitleLabel.textColor = UIColor.gray
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func mapDayOfWeekToString(_ dayOfWeek: DayOfWeek) -> String {
        switch dayOfWeek {
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        case .sunday:
            return "Вс"
        }
    }

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.borderColor = UIColor.red.cgColor
        button.tintColor = UIColor(named: "YPColorSelection1")
        button.backgroundColor = .clear
        button.setTitle("Отменить", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(nil, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

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

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, text.count > 38 {
            charLimitLabel.isHidden = false
        } else {
            charLimitLabel.isHidden = true
        }

        tableViewTopConstraint?.isActive = false
        tableViewTopConstraintWithCharLimit?.isActive = false

        if charLimitLabel.isHidden {
            tableViewTopConstraint?.isActive = true
        } else {
            tableViewTopConstraintWithCharLimit?.isActive = true
        }

        createButton.isEnabled = charLimitLabel.isHidden
        createButton.backgroundColor = charLimitLabel.isHidden ? UIColor.black : UIColor(named: "YPGray")

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    private func addElements() {
        view.addSubview(scrollView)
        view.addSubview(stackView)
        view.addSubview(titleLabel)
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(charLimitLabel)
        scrollView.addSubview(tableView)
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addElements()
        setupView()
        setupTableView()
        updateCreateButtonState()
        view.backgroundColor = UIColor(named: "YPDefaultWhite")
    }

    private func setupView() {
        charLimitLabel.isHidden = true
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24)
        tableViewTopConstraintWithCharLimit = tableView.topAnchor.constraint(equalTo: charLimitLabel.bottomAnchor, constant: 24)
        tableViewTopConstraint?.isActive = charLimitLabel.isHidden
        tableViewTopConstraintWithCharLimit?.isActive = !charLimitLabel.isHidden

        NSLayoutConstraint.activate([
            charLimitLabel.widthAnchor.constraint(equalToConstant: 286),
            charLimitLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            charLimitLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 150),

            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.widthAnchor.constraint(equalToConstant: 343),

            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: stackView.topAnchor),

            tableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 149),
            tableView.widthAnchor.constraint(equalToConstant: 343),

            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34),
        ])
    }

    @objc private func scheduleTapped() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.delegate = self
        present(scheduleViewController, animated: true)
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    private func updateCreateButtonState() {
        let isDataComplete = !(nameTextField.text?.isEmpty ?? true) &&
                !(category?.isEmpty ?? true) &&
                !daysOfWeekCasted.isEmpty

        createButton.backgroundColor = isDataComplete ? UIColor(named: "YPBlack") : UIColor(named: "YPGray")
    }


    private func showAlert() {
        let alertController = UIAlertController(title: "Внимание",
                message: "Заполните все необходимые поля (название, категория, расписание)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc private func createButtonTapped() {
        guard let text = nameTextField.text, !text.isEmpty,
              let category = category, !category.isEmpty,
              !daysOfWeekCasted.isEmpty
        else {
            showAlert()
            return
        }

        if let delegate = delegate {
            delegate.addNewTracker(
                    TrackerCategory(title: category, trackers: [Tracker(id: UUID(),
                            name: text, color: UIColor(named: "YPColorSelection1") ?? .blue,
                            emoji: "😻️",
                            schedule: TrackerSchedule(frequency: .daily,
                                    daysOfWeek: daysOfWeekCasted,
                                    specificDays: []))])
            )
            delegateDidClose?.trackerCreationViewControllerDidClose(self)
        }
        dismiss(animated: true)
    }

    func didSelectWeekdayMask(_ mask: WeekdayMask) {
        daysOfWeek = []
        if mask.contains(.monday) {
            daysOfWeek.append(.monday)
        }
        if mask.contains(.tuesday) {
            daysOfWeek.append(.tuesday)
        }
        if mask.contains(.wednesday) {
            daysOfWeek.append(.wednesday)
        }
        if mask.contains(.thursday) {
            daysOfWeek.append(.thursday)
        }
        if mask.contains(.friday) {
            daysOfWeek.append(.friday)
        }
        if mask.contains(.saturday) {
            daysOfWeek.append(.saturday)
        }
        if mask.contains(.sunday) {
            daysOfWeek.append(.sunday)
        }
        daysOfWeekCasted = []
        daysOfWeekCasted = daysOfWeek.compactMap {
            dayMapping[$0]
        }
        tableView.reloadData()
        updateCreateButtonState()
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}

