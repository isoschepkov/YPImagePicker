//
//  YPLibraryViewCell.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/14.
//  Copyright © 2015 Yummypets. All rights reserved.
//

import Stevia
import UIKit

class YPSingleSelectionIndicator: UIImageView {
    convenience init() {
        self.init(frame: .zero)

        image = Asset.doneIcon.image
        contentMode = .scaleAspectFit
    }
}

class YPMultipleSelectionIndicator: UIView {
    let circle = UIView()
    let label = UILabel()
    var selectionColor = UIColor.black

    convenience init() {
        self.init(frame: .zero)

        let size: CGFloat = 16

        sv(
            circle,
            label
        )

        circle.fillContainer()
        circle.size(size)
        label.fillContainer()

        circle.layer.cornerRadius = size / 2.0
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)

        set(number: nil)
    }

    func set(number: Int?) {
        label.isHidden = (number == nil)
        if let number = number {
            circle.backgroundColor = selectionColor
            label.text = "\(number)"
        } else {
            circle.backgroundColor = .clear
            label.text = ""
        }
    }
}

class YPLibraryViewCell: UICollectionViewCell {
    var representedAssetIdentifier: String!
    let imageView = UIImageView()
    let durationLabel = UILabel()
    let multipleSelectionIndicator = YPMultipleSelectionIndicator()
    let singleSelectionIndicator = YPSingleSelectionIndicator()

    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)

        sv(
            imageView,
            durationLabel,
            multipleSelectionIndicator,
            singleSelectionIndicator
        )

        imageView.fillContainer()
        layout(
            durationLabel - 5-|,
            5
        )

        layout(
            1,
            multipleSelectionIndicator - 1-|
        )

        layout(
            1,
            singleSelectionIndicator - 1-|
        )
        singleSelectionIndicator.size(16)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        durationLabel.textColor = .white
        durationLabel.font = .systemFont(ofSize: 12)
        durationLabel.isHidden = true
        backgroundColor = YPImagePickerConfiguration.shared.colors.libraryBackground
    }

    override var isSelected: Bool {
        didSet { singleSelectionIndicator.alpha = isSelected ? 1.0 : 0.0 }
    }
}
