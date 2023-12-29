//
// Created by Ruslan S. Shvetsov on 27.12.2023.
//

import UIKit

struct WeekdayMask: OptionSet {
    let rawValue: Int

    static let monday    = WeekdayMask(rawValue: 1 << 0)
    static let tuesday   = WeekdayMask(rawValue: 1 << 1)
    static let wednesday = WeekdayMask(rawValue: 1 << 2)
    static let thursday  = WeekdayMask(rawValue: 1 << 3)
    static let friday    = WeekdayMask(rawValue: 1 << 4)
    static let saturday  = WeekdayMask(rawValue: 1 << 5)
    static let sunday    = WeekdayMask(rawValue: 1 << 6)

    static let allDays: WeekdayMask = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
}


enum WeekDay: String, CaseIterable {
    case monday = "Понедельник",
         tuesday = "Вторник",
         wednesday = "Среда",
         thursday = "Четверг",
         friday = "Пятница",
         saturday = "Суббота",
         sunday = "Воскресенье"
}

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectWeekdayMask(_ mask: WeekdayMask)
}

final class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: ScheduleViewControllerDelegate?

    var tableView: UITableView!

    var weekDaySwitchStates: [WeekDay: Bool] = [.monday: false, .tuesday: false, .wednesday: false,
                                                .thursday: false, .friday: false, .saturday: false,
                                                .sunday: false]

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "YPBlack") ?? .black // Fallback to black if custom color not found
        button.setTitle("Готово", for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTableView()
    }

    func setupViews() {
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

        view.addSubview(titleLabel)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
    }

    @objc func doneAction() {
        var mask = WeekdayMask()
        for (day, isOn) in weekDaySwitchStates {
            if isOn {
                switch day {
                case .monday: mask.insert(.monday)
                case .tuesday: mask.insert(.tuesday)
                case .wednesday: mask.insert(.wednesday)
                case .thursday: mask.insert(.thursday)
                case .friday: mask.insert(.friday)
                case .saturday: mask.insert(.saturday)
                case .sunday: mask.insert(.sunday)
                default: break
                }
            }
        }
        delegate?.didSelectWeekdayMask(mask)
        dismiss(animated: true, completion: nil)
    }

    func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                         .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WeekDayCell")
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -60)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekDay.allCases.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekDayCell", for: indexPath)
        let day = WeekDay.allCases[indexPath.row]
        cell.textLabel?.text = day.rawValue
        cell.backgroundColor = UIColor(named: "YPBackground[day]")
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let switchView = UISwitch()
        switchView.onTintColor = UIColor.systemBlue
        switchView.isOn = weekDaySwitchStates[day] ?? false
        switchView.addTarget(self, action: #selector(toggleSwitch(sender:)), for: .valueChanged)
        cell.accessoryView = switchView

        return cell
    }

    @objc func toggleSwitch(sender: UISwitch) {
        if let cell = sender.superview as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell),
           let day = WeekDay(rawValue: cell.textLabel?.text ?? "") {
            weekDaySwitchStates[day] = sender.isOn
        }
    }
}