//
// Created by Ruslan S. Shvetsov on 03.01.2024.
//

import UIKit

final class StatisticTableViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let valueLabel = UILabel()

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        // Устанавливаем путь для градиента, который будет использоваться как рамка
        let borderPath = UIBezierPath(roundedRect: contentView.bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 16).cgPath

        // Удаляем предыдущие градиентные слои, если они есть
        contentView.layer.sublayers?.filter {
                    $0.name == "gradientBorderLayer"
                }
                .forEach {
                    $0.removeFromSuperlayer()
                }

        // Создаем слой с градиентом
        let gradientBorderLayer = CAGradientLayer()
        gradientBorderLayer.frame = contentView.bounds
        gradientBorderLayer.colors = [UIColor.blue.cgColor, UIColor.green.cgColor, UIColor.red.cgColor]
        gradientBorderLayer.startPoint = CGPoint(x: 1, y: 0.5)
        gradientBorderLayer.endPoint = CGPoint(x: 0, y: 0.5)
        gradientBorderLayer.name = "gradientBorderLayer"

        // Создаем слой формы для рамки, который будет использоваться как маска для градиента
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 1
        shapeLayer.path = borderPath
        shapeLayer.fillColor = nil // Без заливки цвета внутри
        shapeLayer.strokeColor = UIColor.black.cgColor // Цвет рамки не важен, так как он будет покрыт градиентом

        // Применяем слой формы как маску для градиентного слоя
        gradientBorderLayer.mask = shapeLayer

        // Добавляем градиентный слой к contentView
        contentView.layer.addSublayer(gradientBorderLayer)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = UIColor(named: "YPBlack")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = UIColor(named: "YPBlack")
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])

        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

