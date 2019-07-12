//
//  YPMultipleSelectionButton.swift
//  Motify
//
//  Created by Semyon Baryshev on 5/24/19.
//  Copyright © 2019 Heads and Hands. All rights reserved.
//

import UIKit

class YPMultipleSelectionButton: UIView {
    private let iconImageView = UIImageView()

    var on: Bool = false {
        didSet {
            if on {
                backgroundColor = YPImagePickerConfiguration.shared.colors.multipleSelectionIconColor ??
                    YPImagePickerConfiguration.shared.colors.tintColor
            } else {
                backgroundColor = YPImagePickerConfiguration.shared.colors.multipleSelectionIconOffColor
            }
        }
    }

    convenience init() {
        self.init(frame: .zero)
        sv(
            iconImageView
        )

        iconImageView.centerHorizontally().centerVertically().size(20)
        iconImageView.image = YPImagePickerConfiguration.shared.icons.multipleSelectionIcon
        iconImageView.contentMode = .scaleAspectFit

        layer.cornerRadius = 16
        clipsToBounds = true
        isUserInteractionEnabled = true
    }
}
