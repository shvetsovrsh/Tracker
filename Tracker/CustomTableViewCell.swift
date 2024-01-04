//
// Created by Ruslan S. Shvetsov on 28.12.2023.
//

import UIKit


final class CustomTableViewCell: UITableViewCell {
    let stackView = UIStackView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = UIColor(named: "YPBlack")

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        subtitleLabel.textColor = UIColor(named: "YPGray")

        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCell(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
