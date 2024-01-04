//
// Created by Ruslan S. Shvetsov on 18.12.2023.
//

import UIKit

final class StatisticViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let placeholderView = PlaceholderView()
    private var tableView: UITableView = UITableView()

    private var statistics: [[String: Any]] = []

    private let dataManager = MockData.shared

    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleHeader: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.textColor = UIColor(named: "YPBlack")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        12
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        statistics.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.gradientCellIdentifier,
                for: indexPath) as? StatisticTableViewCell else {
            fatalError("Unable to dequeue StatisticTableViewCell")
        }

        cell.selectionStyle = .none

        cell.titleLabel.text = statistics[indexPath.section]["title"] as? String
        cell.valueLabel.text = "\(statistics[indexPath.section]["value"] as? Int ?? 0)"

        return cell
    }

    private func reloadData() {
        // TODO 15 sprint add data core functionality
        statistics = [
            ["title": "Лучший период", "value": 6],
            ["title": "Идеальные дни", "value": 2],
            ["title": "Трекеров завершено", "value": 5],
            ["title": "Среднее значение", "value": 4]
        ]
    }

    private func reloadPlaceholders() {
        if statistics.isEmpty {
            placeholderView.isHidden = false
            tableView.isHidden = true
            tableView.alpha = 0
            placeholderView.configure(with: UIImage(named: "ErrorPlaceholder"),
                    text: "Анализировать пока нечего")
        } else {
            placeholderView.isHidden = true
            tableView.isHidden = false
            tableView.alpha = 1
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupTableView()
        reloadData()
        reloadPlaceholders()
    }

    func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StatisticTableViewCell.self,
                forCellReuseIdentifier: Constants.gradientCellIdentifier)

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }

    func setupViews() {
        view.backgroundColor = UIColor(named: "YPWhite")
        view.addSubview(headerView)
        headerView.addSubview(titleHeader)
        view.addSubview(placeholderView)
        view.bringSubviewToFront(placeholderView)
        NSLayoutConstraint.activate([

            headerView.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),

            headerView.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor
            ),

            headerView.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),

            headerView.heightAnchor.constraint(
                    equalToConstant: 137
            ),

            titleHeader.leadingAnchor.constraint(
                    equalTo: headerView.leadingAnchor
                    , constant: 16
            ),

            titleHeader.topAnchor.constraint(
                    equalTo: headerView.topAnchor,
                    constant: 44
            ),

            titleHeader.bottomAnchor.constraint(
                    equalTo: headerView.bottomAnchor,
                    constant: -53
            ),

            placeholderView.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
            ),

            placeholderView.topAnchor.constraint(
                    equalTo: headerView.bottomAnchor,
                    constant: 193
            ),
        ])
    }
}
