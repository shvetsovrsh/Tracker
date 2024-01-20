//
// Created by Ruslan S. Shvetsov on 27.12.2023.
//

import UIKit

final class EventCreationViewController: UIViewController,
        UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    weak var delegate: TrackerCreationViewControllerDelegate?
    weak var delegateDidClose: TrackerCreationViewControllerDidCloseDelegate?
    weak var delegateUpdatingTracker: TrackerUpdatingViewControllerDelegate?

    private var tableViewTopConstraint: NSLayoutConstraint?
    private var tableViewTopConstraintWithCharLimit: NSLayoutConstraint?

    private var nameTextFieldTopConstraint: NSLayoutConstraint?
    private var nameTextFieldTopConstraintWithStatisticLabel: NSLayoutConstraint?

    private var emojiCollectionView: SelectableCollectionView?
    private var colorCollectionView: SelectableCollectionView?

    private let dataManager = ColorAndEmojiData.shared
    private var category: String?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?

    var editingTracker: TrackerCategory?

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
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
        label.text = "Новое нерегулярное событие"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "YPBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var statisticLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(named: "YPBlack")
        label.text = "0 дней"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameTextField: InsetTextField = {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 41)
        let field = InsetTextField(textInsets: insets)
        field.placeholder = "Введите название трекера"
        field.backgroundColor = UIColor(named: "YPBackground")
        field.clearButtonMode = .whileEditing
        field.textColor = UIColor(named: "YPBlack")
        field.font = .systemFont(ofSize: 17, weight: .regular)
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 16
        field.translatesAutoresizingMaskIntoConstraints = false
        field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        field.returnKeyType = .done
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
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: Constants.customTableCellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
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
        let categoryCreationViewController = CategoryCreationViewController()
        categoryCreationViewController.delegate = self
        present(categoryCreationViewController, animated: true)
        tableView.reloadData()
        updateCreateButtonState()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.customTableCellIdentifier, for: indexPath) as! CustomTableViewCell
        cell.backgroundColor = UIColor(named: "YPBackground")
        cell.configureCell(title: "Категория", subtitle: category ?? "")
        cell.accessoryType = .disclosureIndicator
        return cell
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

    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func addElements() {
        view.addSubview(scrollView)
        view.addSubview(titleLabel)

        scrollView.addSubview(statisticLabel)
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(charLimitLabel)
        scrollView.addSubview(tableView)

        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)

        scrollView.addSubview(stackView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addElements()
        setupView()
        setupTableView()
        configureCollectionView(&emojiCollectionView, with: dataManager.emojiData)
        configureCollectionView(&colorCollectionView, with: dataManager.colorData)
        addAndSetupCollectionViews()
        updateCreateButtonState()
        view.backgroundColor = UIColor(named: "YPWhite")
        nameTextField.delegate = self
        configureEditingFunctionality()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureProgrammaticallySelection()
    }

    private func findEmojiIndex(in items: [String], for selectedEmoji: String) -> Int? {
        guard let selectedEmojiFirstScalar = selectedEmoji.unicodeScalars.first?.value else {
            return nil
        }
        for (index, emoji) in items.enumerated() {
            if let emojiFirstScalar = emoji.unicodeScalars.first?.value,
               emojiFirstScalar == selectedEmojiFirstScalar {
                return index
            }
        }
        return nil
    }

    private func configureProgrammaticallySelection() {
        guard let editingTrackerCategory = editingTracker?.title,
              let editingTrackerData = editingTracker?.trackers.first
        else {
            return
        }

        if let emojiItems = dataManager.emojiData.items as? [String] {
            let selectedEmoji = editingTrackerData.emoji
            if let index = findEmojiIndex(in: emojiItems, for: editingTrackerData.emoji) {
                let indexPath = IndexPath(item: index, section: 0)
                emojiCollectionView?.selectItem(at: indexPath, animated: false, scrollPosition: [])
                emojiCollectionView?.collectionView(emojiCollectionView!, didSelectItemAt: indexPath)
            }
        }

        let dynamicColor = editingTrackerData.color
        let standardColor = UIColor(cgColor: dynamicColor.cgColor)

        if let colorItems = dataManager.colorData.items as? [UIColor] {
            if let selectedColorIndex = colorItems.firstIndex(where: { itemColor in
                let itemComponents = itemColor.cgColor.components
                let standardComponents = standardColor.cgColor.components

                return itemComponents?.elementsEqual(standardComponents ?? []) ?? false
            }) {
                let indexPath = IndexPath(item: selectedColorIndex, section: 0)
                colorCollectionView?.selectItem(at: indexPath, animated: false, scrollPosition: [])
                colorCollectionView?.collectionView(colorCollectionView!, didSelectItemAt: indexPath)
            }
        }
    }

    private func configureEditingFunctionality() {
        guard let editingTrackerCategory = editingTracker?.title,
              let editingTrackerData = editingTracker?.trackers.first
        else {
            return
        }
        statisticLabel.isHidden = false
        let completedDays = editingTrackerData.completedDays
        statisticLabel.text = LocalizationHelper.pluralizeDays(for: completedDays)
        nameTextField.text = editingTrackerData.name
        category = editingTrackerCategory
        titleLabel.text = "Редактирование привычки"
        createButton.setTitle("Сохранить", for: .normal)
        updateCreateButtonState()
        updateLayoutForStatisticLabel()
    }

    private func updateLayoutForStatisticLabel() {
        nameTextFieldTopConstraint?.isActive = statisticLabel.isHidden
        nameTextFieldTopConstraintWithStatisticLabel?.isActive = !statisticLabel.isHidden
    }

    private func updateLayoutForCharLimitLabel() {
        tableViewTopConstraint?.isActive = charLimitLabel.isHidden
        tableViewTopConstraintWithCharLimit?.isActive = !charLimitLabel.isHidden
    }

    private func addAndSetupCollectionViews() {
        if let emojiCollectionView = emojiCollectionView {
            scrollView.addSubview(emojiCollectionView)
            setupCollectionView(emojiCollectionView)
        }

        if let colorCollectionView = colorCollectionView {
            scrollView.addSubview(colorCollectionView)
            setupCollectionView(colorCollectionView)
        }
    }

    private func configureCollectionView(_ collectionView: inout SelectableCollectionView?,
                                         with dataSource: SelectableCollectionDataSource) {
        let layout = UICollectionViewFlowLayout()
        collectionView = SelectableCollectionView(frame: .zero,
                collectionViewLayout: layout,
                dataSource: dataSource)
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.selectionDelegate = self
    }

    private func setupCollectionView(_ collectionView: SelectableCollectionView) {
        if collectionView == emojiCollectionView {
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            ])

        } else {
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 265),
                stackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            ])
        }
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor
                    , constant: 18
            ),
            collectionView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 204 + 46)
        ])
    }

    private func setupView() {
        charLimitLabel.isHidden = true
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24)
        tableViewTopConstraintWithCharLimit = tableView.topAnchor.constraint(equalTo: charLimitLabel.bottomAnchor, constant: 24)
        updateLayoutForCharLimitLabel()

        statisticLabel.isHidden = true
        nameTextFieldTopConstraint = nameTextField.topAnchor.constraint(equalTo: scrollView.topAnchor)
        nameTextFieldTopConstraintWithStatisticLabel = nameTextField.topAnchor.constraint(equalTo: statisticLabel.bottomAnchor, constant: 40)
        updateLayoutForStatisticLabel()

        NSLayoutConstraint.activate([
            statisticLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            statisticLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),

            charLimitLabel.widthAnchor.constraint(equalToConstant: 286),
            charLimitLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            charLimitLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 74),
            tableView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    private func updateCreateButtonState() {
        let isDataComplete = !(nameTextField.text?.isEmpty ?? true) &&
                !(category?.isEmpty ?? true)

        createButton.backgroundColor = isDataComplete ? UIColor(named: "YPBlack") : UIColor(named: "YPGray")
    }


    private func showAlert() {
        let alertController = UIAlertController(title: "Внимание",
                message: "Заполните все необходимые поля (название, категория)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc private func createButtonTapped() {
        guard let text = nameTextField.text, !text.isEmpty,
              let category = category, !category.isEmpty
        else {
            showAlert()
            return
        }

        if let delegate = delegate {
            delegate.addNewTracker(
                    TrackerCategory(title: category, trackers: [Tracker(id: UUID(),
                            name: text,
                            color: selectedColor ?? UIColor(named: "YPColorSelection1") ?? .blue,
                            emoji: selectedEmoji ?? "😻️",
                            schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
                            isHabit: false,
                            isPinned: false,
                            completedDays: 0,
                            previousCategory: nil
                    )])
            )
            delegateDidClose?.trackerCreationViewControllerDidClose(self)
        }

        if let delegate = delegateUpdatingTracker,
           let editingTracker = editingTracker,
           let editingTrackerData = editingTracker.trackers.first {
            delegate.updateTracker(
                    TrackerCategory(title: category, trackers: [Tracker(id: editingTrackerData.id,
                            name: text,
                            color: selectedColor ?? UIColor(named: "YPColorSelection1") ?? .blue,
                            emoji: selectedEmoji ?? "😻️",
                            schedule: editingTrackerData.schedule,
                            isHabit: editingTrackerData.isHabit,
                            isPinned: editingTrackerData.isPinned,
                            completedDays: editingTrackerData.completedDays,
                            previousCategory: category
                    )])
            )
        }

        dismiss(animated: true)
    }
}

extension EventCreationViewController: CategoryCreationViewControllerDelegate {
    func categoryCreationViewController(_ controller: CategoryCreationViewController, didSelectCategory category: TrackerCategory) {
        self.category = category.title
        tableView.reloadData()
        updateCreateButtonState()
    }
}

extension EventCreationViewController: SelectableCollectionViewDelegate {
    func didSelectItem(_ collectionView: SelectableCollectionView, item: Any) {
        if collectionView === emojiCollectionView {
            if let emoji = item as? String {
                selectedEmoji = emoji
            }
        } else if collectionView === colorCollectionView {
            if let color = item as? UIColor {
                selectedColor = color
            }
        }
    }
}
