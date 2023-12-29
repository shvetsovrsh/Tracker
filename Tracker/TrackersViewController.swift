//
// Created by Ruslan S. Shvetsov on 01.09.2023.
//

import UIKit

final class TrackersViewController: UIViewController {

    enum PlaceholdersTypes {
        case noTrackers
        case notFoundTrackers
    }

    struct Constants {
        static let taskCellIdentifier = "TaskCell"
        static let headerCellIdentifier = "HeaderCell"
    }

    struct GeometricParams {
        let cellCount: Int
        let leftInset: CGFloat
        let rightInset: CGFloat
        let cellSpacing: CGFloat
        // Параметр вычисляется уже при создании, что экономит время на вычислениях при отрисовке коллекции.
        let paddingWidth: CGFloat

        init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
            self.cellCount = cellCount
            self.leftInset = leftInset
            self.rightInset = rightInset
            self.cellSpacing = cellSpacing
            paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
        }
    }

    let params = GeometricParams(cellCount: 2,
            leftInset: 16,
            rightInset: 16,
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
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.backgroundColor = UIColor(named: "YPBackground")
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

    private let dataManager = MockData.shared

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
        configureView()
        addElements()
        setupConstraints()
        setupCollectionView()
        searchTextField.delegate = self
        reloadPlaceholders(for: .noTrackers)
        updateDateLabelTitle(with: Date())
    }

    //MARK: - Helpers

    private func configureView() {
        view.backgroundColor = UIColor(named: "YPBackground")
        searchTextField.returnKeyType = .done
        filterButton.layer.zPosition = 2
    }

    private func reloadData() {
        categories = dataManager.categories
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
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.headerCellIdentifier
        )

        collectionView.backgroundColor = .clear
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            headerView.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 16
            ),

            headerView.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: 13
            ),

            headerView.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -16
            ),

            headerView.heightAnchor.constraint(equalToConstant: 138),

            addButton.leadingAnchor.constraint(
                    equalTo: headerView.leadingAnchor,
                    constant: 2
            ),

            addButton.topAnchor.constraint(
                    equalTo: headerView.topAnchor
            ),

            titleHeader.leadingAnchor.constraint(
                    equalTo: headerView.leadingAnchor
            ),
            titleHeader.topAnchor.constraint(
                    equalTo: addButton.bottomAnchor,
                    constant: 21
            ),


            dateLabel.trailingAnchor.constraint(
                    equalTo: headerView.trailingAnchor
            ),
            dateLabel.centerYAnchor.constraint(
                    equalTo: titleHeader.centerYAnchor
            ),
            dateLabel.widthAnchor.constraint(
                    equalToConstant: 77
            ),
            dateLabel.heightAnchor.constraint(
                    equalToConstant: 34
            ),


            datePicker.trailingAnchor.constraint(
                    equalTo: headerView.trailingAnchor
            ),

            datePicker.centerYAnchor.constraint(
                    equalTo: titleHeader.centerYAnchor
            ),
            datePicker.widthAnchor.constraint(
                    equalToConstant: 77
            ),

            datePicker.heightAnchor.constraint(
                    equalToConstant: 34
            ),

            searchStackView.leadingAnchor.constraint(
                    equalTo: headerView.leadingAnchor
            ),

            searchStackView.bottomAnchor.constraint(
                    equalTo: headerView.bottomAnchor, constant: -10
            ),

            searchStackView.trailingAnchor.constraint(
                    equalTo: headerView.trailingAnchor
            ),

            placeholderView.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
            ),

            placeholderView.topAnchor.constraint(
                    equalTo: headerView.bottomAnchor,
                    constant: 220
            ),

            collectionView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor
            ),

            collectionView.topAnchor.constraint(
                    equalTo: headerView.bottomAnchor
            ),


            collectionView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor
            ),

            collectionView.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),

            filterButton.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -17
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

                let dateCondition = tracker.schedule.daysOfWeek.contains(dayOfWeekArray[filterWeekDay])

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
        reloadPlaceholders(for: .noTrackers)
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
                completedTrackers.remove(at: index)
            } else {
                let trackerRecord = TrackerRecord(
                        trackerID: tracker.id, date: currentDate
                )
                completedTrackers.append(trackerRecord)
            }
            collectionView.reloadItems(at: [indexPath])
        }
        else {
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
            return CGSizeZero
        }
        let headerView = self.collectionView(
                collectionView,
                viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
                at: indexPath)

        return headerView.systemLayoutSizeFitting(
                CGSize(width: collectionView.frame.width,
                        height: UIView.layoutFittingExpandedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel)
    }
}


extension TrackersViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        reloadVisibleCategories(text: searchTextField.text, date: datePicker.date)
        return true
    }
}

extension TrackersViewController: HabitCreationViewControllerDelegate {
    func addNewTracker(_ trackerCategory: TrackerCategory) {
        var newCategories: [TrackerCategory] = []

        if let categoryIndex = categories.firstIndex(where: { $0.title == trackerCategory.title }) {
            for (index, category) in categories.enumerated() {
                var trackers = category.trackers
                if index == categoryIndex {
                    trackers.append(contentsOf: trackerCategory.trackers)
                }
                newCategories.append(TrackerCategory(title: category.title, trackers: trackers))
            }
        } else {
            newCategories = categories
            newCategories.append(trackerCategory)
            print(newCategories)
        }
        categories = newCategories
        collectionView.reloadData()
        reloadVisibleCategories(text: searchTextField.text, date: datePicker.date)
    }
}
