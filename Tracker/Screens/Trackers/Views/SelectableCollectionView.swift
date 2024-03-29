//
// Created by Ruslan S. Shvetsov on 03.01.2024.
//

import UIKit

protocol SelectableCollectionDataSource {
    var items: [Any] { get }
    var title: String { get }
}

protocol SelectableCollectionViewDelegate: AnyObject {
    func didSelectItem(_ collectionView: SelectableCollectionView, item: Any)
}

final class SelectableCollectionView: UICollectionView,
        UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var dataSourceObject: SelectableCollectionDataSource?
    private var selectedItemIndex: IndexPath?
    weak var selectionDelegate: SelectableCollectionViewDelegate?


    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout,
         dataSource: SelectableCollectionDataSource) {
        super.init(frame: frame, collectionViewLayout: layout)
        dataSourceObject = dataSource
        delegate = self
        self.dataSource = self
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Constants.collectionViewCellIdentifier)
        self.register(HeaderSectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: Constants.headerCellIdentifier)
        backgroundColor = UIColor(named: "YPWhite")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSourceObject?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.headerCellIdentifier, for: indexPath) as? HeaderSectionView else {
            return UICollectionReusableView()
        }

        if let titleCategory = dataSourceObject?.title {
            view.configureHeader(with: titleCategory)
        }
        return view
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(item: 0, section: section)
        if dataSourceObject?.items.count == 0 {
            return CGSize.zero
        }
        return CGSize(width: collectionView.frame.width, height: 46)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.collectionViewCellIdentifier, for: indexPath)
        configureCell(cell, with: dataSourceObject?.items[indexPath.item], at: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let oldIndex = selectedItemIndex {
            let oldCell = collectionView.cellForItem(at: oldIndex)
            oldCell?.contentView.subviews.forEach { subview in
                if subview is UILabel {
                    subview.backgroundColor = .clear
                } else if let colorView = subview as? UIView {
                    if subview.tag == 99 {
                        subview.removeFromSuperview()
                    }
                }
            }
        }

        let cell = collectionView.cellForItem(at: indexPath)
        selectedItemIndex = indexPath
        cell?.contentView.subviews.forEach { subview in
            if let label = subview as? UILabel {
                label.backgroundColor = UIColor(named: "YPLightGray")
                label.layer.cornerRadius = 16
                label.clipsToBounds = true
            } else if let colorView = subview as? UIView {
                let frameView = UIView()
                frameView.backgroundColor = .clear
                frameView.layer.borderWidth = 3
                frameView.layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
                frameView.frame = CGRect(x: colorView.frame.minX - 6,
                        y: colorView.frame.minY - 6,
                        width: colorView.frame.width + 12,
                        height: colorView.frame.height + 12)
                frameView.layer.cornerRadius = 8
                frameView.tag = 99
                cell?.contentView.insertSubview(frameView, belowSubview: colorView)
            }
        }
        if let selectedItem = dataSourceObject?.items[indexPath.item] {
            selectionDelegate?.didSelectItem(self, item: selectedItem)
        }
    }

    private func configureCell(_ cell: UICollectionViewCell, with item: Any, at indexPath: IndexPath) {
        if let obj = item as? String {
            let label = UILabel()
            label.text = obj
            label.font = .systemFont(ofSize: 32)
            label.textAlignment = .center
            cell.contentView.addSubview(label)
            label.frame = cell.bounds
        } else if let color = item as? UIColor {
            let colorView = UIView()
            colorView.backgroundColor = color
            colorView.layer.cornerRadius = 8
            colorView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            cell.contentView.addSubview(colorView)
            colorView.center = cell.contentView.center
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 6
        let paddingWidth = 5 * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
}
