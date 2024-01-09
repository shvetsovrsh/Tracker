//
// Created by Ruslan S. Shvetsov on 01.09.2023.
//

import UIKit

enum PlaceholdersTypes {
    case noTrackers
    case notFoundTrackers
}

final class TrackersViewController: UIViewController {

    let params = GeometricParams(cellCount: 2,
            leftInset: 0,
            rightInset: 0,
            cellSpacing: 9)


    //MARK: - Properties
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "PlusImage"), for: .normal)
        button.tintColor = UIColor(named: "YPBlack")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)
        return button
    }()

    private let trackerStore = TrackerStore.shared
    private let categoryStore = TrackerCategoryStore.shared
    private let recordStore = TrackerRecordStore.shared
    private let dataManager = MockData.shared

    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()

    private let navigationBar = UINavigationBar()

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let titleHeader: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = UIColor(named: "YPBlack")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(named: "YPBackgroundDatePicker")
        label.textColor = UIColor(named: "YPDefaultBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 5
        label.layer.zPosition = 10
        return label
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")

        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        var calendar = Calendar.current
        picker.calendar = calendar
        picker.clipsToBounds = true
        picker.layer.cornerRadius = 5
        picker.tintColor = UIColor(named: "YPBlue")
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()

    private let searchStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.backgroundColor = UIColor(named: "YPWhite")
        textField.textColor = UIColor(named: "YPBlack")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 10
        textField.heightAnchor.constraint(equalToConstant: 36).isActive = true

        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "YPGray")
        ]

        let attributedPlaceholder = NSAttributedString(
                string: "Поиск",
                attributes: attributes as [NSAttributedString.Key: Any]
        )
        textField.attributedPlaceholder = attributedPlaceholder

        return textField
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.tintColor = UIColor(named: "YPBlue")
        button.isHidden = true
        button.addTarget(nil, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    private let placeholderView = PlaceholderView()

    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Фильтры", for: .normal)
        button.backgroundColor = UIColor(named: "YPBlue")

        button.tintColor = UIColor(named: "YPDefaultWhite")
        button.addTarget(
                self,
                action: #selector(selectFilter),
                for: .touchUpInside
        )
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()


    init(categories: [TrackerCategory], visibleCategories: [TrackerCategory], completedTrackers: [TrackerRecord], currentDate: Date) {
        self.categories = categories
        self.visibleCategories = visibleCategories
        self.completedTrackers = completedTrackers
        self.currentDate = currentDate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(dataDidUpdate),
                name: .trackerCategoryStoreDidUpdate, object: nil)
        reloadData()
        configureView()
        addElements()
        setupConstraints()
        setupCollectionView()
        searchTextField.delegate = self
        reloadPlaceholders(for: .noTrackers)
        updateDateLabelTitle(with: Date())
    }

    @objc private func dataDidUpdate() {
        reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: - Helpers

    private func configureView() {
        view.backgroundColor = UIColor(named: "YPWhite")
        searchTextField.returnKeyType = .done
        filterButton.layer.zPosition = 2
    }

    private func reloadData() {
        categories = categoryStore.categories
        completedTrackers = recordStore.records
        dateChanged()
    }

    private func addElements() {
        view.addSubview(headerView)
        view.addSubview(placeholderView)
        view.addSubview(navigationBar)
        view.addSubview(searchTextField)
        view.addSubview(collectionView)
        view.addSubview(filterButton)

        headerView.addSubview(addButton)
        headerView.addSubview(titleHeader)
        headerView.addSubview(dateLabel)
        headerView.addSubview(datePicker)
        headerView.addSubview(searchStackView)

        searchStackView.addArrangedSubview(searchTextField)
        searchStackView.addArrangedSubview(cancelButton)
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(
                TrackerCell.self,
                forCellWithReuseIdentifier: Constants.taskCellIdentifier
        )

        collectionView.register(
                HeaderSectionView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: Constants.headerCellIdentifier
        )

        collectionView.backgroundColor = .clear
    }

    private func setupConstraints() {
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

            addButton.leadingAnchor.constraint(
                    equalTo: headerView.leadingAnchor
                    , constant: 6
            ),

            addButton.topAnchor.constraint(
                    equalTo: headerView.topAnchor
                    , constant: 1
            ),

            addButton.heightAnchor.constraint(
                    equalToConstant: 42
            ),

            addButton.widthAnchor.constraint(
                    equalToConstant: 42
            ),

            titleHeader.leadingAnchor.constraint(
                    equalTo: headerView.leadingAnchor
                    , constant: 16
            ),

            titleHeader.topAnchor.constraint(
                    equalTo: addButton.bottomAnchor,
                    constant: 1
            ),

            dateLabel.trailingAnchor.constraint(
                    equalTo: headerView.trailingAnchor
                    , constant: -16
            ),

            dateLabel.centerYAnchor.constraint(
                    equalTo: addButton.centerYAnchor
            ),

            dateLabel.widthAnchor.constraint(
                    equalToConstant: 77
            ),

            dateLabel.heightAnchor.constraint(
                    equalToConstant: 34
            ),


            datePicker.trailingAnchor.constraint(
                    equalTo: headerView.trailingAnchor
                    , constant: -16
            ),

            datePicker.centerYAnchor.constraint(
                    equalTo: addButton.centerYAnchor
            ),

            datePicker.widthAnchor.constraint(
                    equalToConstant: 77
            ),

            datePicker.heightAnchor.constraint(
                    equalToConstant: 34
            ),

            searchStackView.leadingAnchor.constraint(
                    equalTo: headerView.leadingAnchor
                    , constant: 16
            ),

            searchStackView.bottomAnchor.constraint(
                    equalTo: headerView.bottomAnchor, constant: -10
            ),

            searchStackView.trailingAnchor.constraint(
                    equalTo: headerView.trailingAnchor
                    , constant: -16
            ),

            placeholderView.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
            ),

            placeholderView.topAnchor.constraint(
                    equalTo: headerView.bottomAnchor,
                    constant: 220
            ),

            collectionView.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor
                    , constant: 16
            ),

            collectionView.topAnchor.constraint(
                    equalTo: headerView.bottomAnchor
                    , constant: 8
            ),

            collectionView.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor
                    , constant: -16
            ),

            collectionView.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),

            filterButton.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -16
            ),

            filterButton.heightAnchor.constraint(
                    equalToConstant: 50
            ),
            filterButton.widthAnchor.constraint(
                    equalToConstant: 114
            ),

            filterButton.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
            ),
        ])
    }

    private func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "dd.MM.yy"

        return dateFormatter.string(from: date)

    }

    private func updateDateLabelTitle(with date: Date) {
        let dateString = formattedDate(from: date)
        dateLabel.text = dateString

    }

    @objc private func selectFilter() {
        print("Tapped filter")
    }

    @objc private func dateChanged() {
        updateDateLabelTitle(with: datePicker.date)
        reloadVisibleCategories(text: searchTextField.text, date: datePicker.date)
    }

    private func reloadVisibleCategories(text: String?, date: Date) {
        let calendar = Calendar.current
        let dayOfWeekArray: [DayOfWeek] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        let filterWeekDay = calendar.component(.weekday, from: date) - 1
        let filterText = (text ?? "").lowercased()

        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty ||
                        tracker.name.lowercased().contains(filterText)

                let dateCondition = tracker.schedule.contains(dayOfWeekArray[filterWeekDay])

                return textCondition && dateCondition
            }

            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(
                    title: category.title,
                    trackers: trackers
            )
        }
        collectionView.reloadData()
        if filterText != "" {
            reloadPlaceholders(for: .notFoundTrackers)
        } else {
            reloadPlaceholders(for: .noTrackers)
        }
    }

    private func reloadPlaceholders(for type: PlaceholdersTypes) {
        if visibleCategories.isEmpty {
            placeholderView.isHidden = false
            switch type {
            case .noTrackers:
                placeholderView.configure(with: UIImage(named: "ImagePlaceholder"), text: "Что будем отслеживать?")
            case .notFoundTrackers:
                placeholderView.configure(with: UIImage(named: "NotFoundPlaceholder"), text: "Ничего не найдено")
            }
        } else {
            placeholderView.isHidden = true
        }
    }

    @objc private func addTrackerButtonTapped() {
        let trackerCreationViewController = TrackerCreationViewController(delegate: self)
        let navigationViewController = UINavigationController(rootViewController: trackerCreationViewController)
        present(navigationViewController, animated: true)
    }

    @objc private func cancelButtonTapped() {
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        reloadVisibleCategories(text: nil, date: Date())
        cancelButton.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}


extension TrackersViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.headerCellIdentifier, for: indexPath) as? HeaderSectionView else {
            return UICollectionReusableView()
        }


        let titleCategory = visibleCategories[indexPath.section].title

        view.configureHeader(with: titleCategory)

        return view
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let trackers = visibleCategories[section].trackers
        return trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.taskCellIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }


        let cellData = visibleCategories
        let tracker = cellData[indexPath.section].trackers[indexPath.row]
        let completedDays = completedTrackers.filter {
                    $0.trackerID == tracker.id
                }
                .count

        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)

        cell.delegate = self

        cell.configure(
                for: cell,
                tracker: tracker,
                title: tracker.name,
                color: tracker.color,
                emoji: tracker.emoji,
                indexPath: indexPath,
                completedDays: completedDays,
                isCompletedToday: isCompletedToday
        )
        return cell
    }

    func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.trackerID == id && isSameDay
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        params.leftInset
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
}


extension TrackersViewController: TrackersViewControllerDelegate {
    func updateCollectionView() {
        reloadData()
        collectionView.reloadData()
    }

    func updateButtonStateFromDate() -> Date {
        datePicker.date
    }

    func updateCompletedTrackers(tracker: Tracker, at indexPath: IndexPath) {
        let currentDate = datePicker.date
        if currentDate <= Date() {
            if let index = completedTrackers.firstIndex(where: {
                $0.trackerID == tracker.id &&
                        Calendar.current.isDate($0.date, inSameDayAs: currentDate)
            }) {
                let record = completedTrackers.remove(at: index)
                recordStore.removeRecord(for: record.trackerID, date: record.date)
            } else {
                let trackerRecord = TrackerRecord(trackerID: tracker.id, date: currentDate)
                completedTrackers.append(trackerRecord)
                recordStore.addRecord(for: trackerRecord.trackerID, date: trackerRecord.date)
            }
            collectionView.reloadItems(at: [indexPath])
        } else {
            print("Нельзя обновлять счетчик для будущей даты")
        }
    }

}


extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 167, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: params.leftInset, bottom: 0, right: params.rightInset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(item: 0, section: section)
        if visibleCategories[indexPath.section].trackers.count == 0 {
            return CGSize.zero
        }
        return CGSize(width: collectionView.frame.width, height: 46)
    }
}


extension TrackersViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        reloadVisibleCategories(text: searchTextField.text, date: datePicker.date)
        cancelButton.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        return true
    }
}


extension TrackersViewController: TrackerCreationViewControllerDelegate {
    func addNewTracker(_ trackerCategory: TrackerCategory) {
        if let tracker = trackerCategory.trackers.first {
            TrackerCategoryStore.shared.addNewTracker(tracker, toCategoryWithTitle: trackerCategory.title) { [self] in
                collectionView.reloadData()
                reloadVisibleCategories(text: searchTextField.text, date: datePicker.date)
            }
        } else {
            print("Error: No trackers in category")
        }
    }
}
