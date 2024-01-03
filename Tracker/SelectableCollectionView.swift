//
// Created by Ruslan S. Shvetsov on 03.01.2024.
//

import UIKit

protocol SelectableCollectionDataSource {
    var items: [Any] { get }
    var title: String { get }
}

class SelectableCollectionView: UICollectionView,
        UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var dataSourceObject: SelectableCollectionDataSource!
    var selectedItemIndex: IndexPath?


    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout,
         dataSource: SelectableCollectionDataSource) {
        super.init(frame: frame, collectionViewLayout: layout)
        dataSourceObject = dataSource
        delegate = self
        self.dataSource = self
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        backgroundColor = UIColor(named: "YPWhite")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSourceObject.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        configureCell(cell, with: dataSourceObject.items[indexPath.item], at: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let oldIndex = selectedItemIndex {
            let oldCell = collectionView.cellForItem(at: oldIndex)
            oldCell?.layer.borderWidth = 0
        }

        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 3
        cell?.layer.borderColor = UIColor.gray.cgColor

        selectedItemIndex = indexPath
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
            cell.backgroundColor = color
        }

        if indexPath == selectedItemIndex {
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor.gray.cgColor
        } else {
            cell.layer.borderWidth = 0
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
