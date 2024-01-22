//
// Created by Ruslan S. Shvetsov on 10.01.2024.
//

import UIKit

final class NewCategoryViewController: UIViewController, UITextFieldDelegate {

    var editingCategory: TrackerCategory?

    private let dataManager = CategoryCreationViewModel(categoryStore: TrackerCategoryStore.shared)

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
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
        field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        field.returnKeyType = .done
        return field
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(named: "YPWhite"), for: .normal)
        button.tintColor = UIColor(named: "YPWhite")
        button.backgroundColor = UIColor(named: "YPGray")
        button.setTitle("Готово", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(nil, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        nameTextField.delegate = self
        configureEditingFunctionality()
    }

    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func configureEditingFunctionality() {
        guard let editingCategoryTitle = editingCategory?.title
        else {
            return
        }
        nameTextField.text = editingCategoryTitle
        titleLabel.text = "Редактирование категории"
    }

    private func setupViews() {
        view.backgroundColor = UIColor(named: "YPWhite")
        [titleLabel,
         nameTextField,
         doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),

            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextField.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, text.count > 0 {
            doneButton.isEnabled = true
            doneButton.backgroundColor = UIColor(named: "YPBlack")
        } else {
            doneButton.isEnabled = false
            doneButton.backgroundColor = UIColor(named: "YPGray")
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func doneButtonTapped() {
        guard let title = nameTextField.text, !title.isEmpty else {
            return
        }

        if let editingCategory {
            dataManager.editCategory(for: editingCategory, withTitle: title, completionHandler: {})
        } else {
            dataManager.addCategory(withTitle: title, completionHandler: {})
        }
        dismiss(animated: true, completion: nil)
    }
}
