//
// Created by Ruslan S. Shvetsov on 02.01.2024.
//

import UIKit

protocol CategoryCreationViewControllerDelegate: AnyObject {
    func categoryCreationViewController(_ controller: CategoryCreationViewController, didSelectCategory category: TrackerCategory)
}


final class CategoryCreationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: CategoryCreationViewControllerDelegate?

    private let placeholderView = PlaceholderView()
    private var tableView: UITableView = UITableView()

//    private let dataManager = CategoryCreationViewModel(categoryStore: MockData.shared)
    private let dataManager = CategoryCreationViewModel(categoryStore: TrackerCategoryStore.shared)
    private var selectedCategoryIndex: Int?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "YPBlack") ?? .black
        button.setTitle("Добавить категорию", for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private func reloadPlaceholders() {
        if dataManager.isEmpty() {
            placeholderView.isHidden = false
            tableView.isHidden = true
            tableView.alpha = 0
            placeholderView.configure(with: UIImage(named: "ImagePlaceholder"),
                    text: "Привычки и события можно объединить по смыслу")
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
        reloadPlaceholders()

        NotificationCenter.default.addObserver(
                self,
                selector: #selector(storeDidUpdate),
                name: .trackerCategoryStoreDidUpdate,
                object: nil
        )
    }

    @objc private func storeDidUpdate() {
        tableView.reloadData()
        reloadPlaceholders()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupViews() {
        view.backgroundColor = UIColor(named: "YPWhite")
        view.addSubview(titleLabel)
        view.addSubview(doneButton)
        view.addSubview(placeholderView)
        view.bringSubviewToFront(placeholderView)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),

            placeholderView.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
            ),

            placeholderView.topAnchor.constraint(
                    equalTo: titleLabel.bottomAnchor,
                    constant: 246
            ),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
    }

    @objc private func doneAction() {
        if selectedCategoryIndex == nil || dataManager.isEmpty() {
            let newCategoryViewController = NewCategoryViewController()
            present(newCategoryViewController, animated: true)
        } else {
            if let selectedIndex = selectedCategoryIndex,
               let selectedCategory = dataManager.selectCategory(at: selectedIndex) {
                delegate?.categoryCreationViewController(self, didSelectCategory: selectedCategory)
            }
            dismiss(animated: true, completion: nil)
        }
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.categoryCellIdentifier)
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
        dataManager.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.categoryCellIdentifier, for: indexPath)

        if let category = dataManager.category(at: indexPath) {
            cell.textLabel?.text = category.title
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

        if indexPath.row == selectedCategoryIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = selectedCategoryIndex {
            let previousIndexPath = IndexPath(row: index, section: 0)
            tableView.cellForRow(at: previousIndexPath)?.accessoryType = .none
        }
        selectedCategoryIndex = indexPath.row
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)

        if let selectedCategory = dataManager.category(at: indexPath) {
            delegate?.categoryCreationViewController(self, didSelectCategory: selectedCategory)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = indexPath.row == selectedCategoryIndex ? .checkmark : .none
    }
}
