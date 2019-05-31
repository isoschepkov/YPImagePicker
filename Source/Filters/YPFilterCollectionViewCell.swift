//
//  YPFilterCollectionViewCell.swift
//  photoTaking
//
//  Created by Sacha Durand Saint Omer on 21/10/16.
//  Copyright © 2016 octopepper. All rights reserved.
//

import Stevia
import UIKit

class YPFilterCollectionViewCell: UICollectionViewCell {
    let name = UILabel()
    let imageView = UIImageView()
    override var isHighlighted: Bool { didSet {
        UIView.animate(withDuration: 0.1) {
            self.contentView.transform = self.isHighlighted
                ? CGAffineTransform(scaleX: 0.95, y: 0.95)
                : CGAffineTransform.identity
        }
    }
    }

    override var isSelected: Bool { didSet {
        name.textColor = isSelected
            ? UIColor(r: 38, g: 38, b: 38)
            : UIColor(r: 154, g: 154, b: 154)

        name.font = .systemFont(ofSize: 11, weight: isSelected
            ? UIFont.Weight.medium
            : UIFont.Weight.regular)
    }
    }

    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)

        sv(
            name,
            imageView
        )

        |name|.steviaTop(0)
        |imageView|.steviaBottom(0).heightEqualsWidth()

        name.font = .systemFont(ofSize: 11, weight: UIFont.Weight.regular)
        name.textColor = UIColor(r: 154, g: 154, b: 154)
        name.textAlignment = .center

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        clipsToBounds = false
        layer.shadowColor = UIColor(r: 46, g: 43, b: 37).cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 4, height: 7)
        layer.shadowRadius = 5
        layer.backgroundColor = UIColor.clear.cgColor
    }
}
