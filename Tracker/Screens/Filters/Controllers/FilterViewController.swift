//
// Created by Ruslan S. Shvetsov on 20.01.2024.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterSelected(_ filter: FilterType)
}


final class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var tableView: UITableView = UITableView()
    private let dataManager = FilterData.shared
    private var selectedFilterIndex: Int?

    weak var delegate: FilterViewControllerDelegate?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTableView()
        selectedFilterIndex = UserDefaults.selectedFilter
        tableView.reloadData()
    }

    private func setupViews() {
        view.backgroundColor = UIColor(named: "YPWhite")
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
        ])
    }

    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                         .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.isScrollEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.filterCellIdentifier)
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataManager.getSize()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.filterCellIdentifier, for: indexPath)

        if let filter = dataManager.getFilter(at: indexPath) {
            cell.textLabel?.text = filter.name
        }

        cell.backgroundColor = UIColor(named: "YPBackground")
        if indexPath.row == dataManager.getSize() - 1 {
            cell.layer.cornerRadius = 10
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.width)
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.maskedCorners = []
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }

        if indexPath.row == selectedFilterIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.selectedFilter = indexPath.row

        if let index = selectedFilterIndex {
            let previousIndexPath = IndexPath(row: index, section: 0)
            tableView.cellForRow(at: previousIndexPath)?.accessoryType = .none
        }

        selectedFilterIndex = indexPath.row
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()

        if let filter = dataManager.getFilter(at: indexPath) {
            delegate?.filterSelected(filter)
        }

        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = indexPath.row == selectedFilterIndex ? .checkmark : .none
    }
}