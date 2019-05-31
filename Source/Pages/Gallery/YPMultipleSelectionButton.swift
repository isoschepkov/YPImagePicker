//
//  YPMultipleSelectionButton.swift
//  Motify
//
//  Created by Semyon Baryshev on 5/24/19.
//  Copyright © 2019 Heads and Hands. All rights reserved.
//

import UIKit

class YPMultipleSelectionButton: UIView {
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    private let iconImageView = UIImageView()

    var on: Bool = false {
        didSet {
            if on {
                blurEffectView.isHidden = true
                backgroundColor = YPImagePickerConfiguration.shared.colors.multipleSelectionIconColor ??
                    YPImagePickerConfiguration.shared.colors.tintColor
            } else {
                blurEffectView.isHidden = false
                backgroundColor = .clear
            }
        }
    }

    convenience init() {
        self.init(frame: .zero)
        sv(
            blurEffectView,
            iconImageView
        )
        blurEffectView.fillContainer()

        iconImageView.centerHorizontally().centerVertically().size(20)
        iconImageView.image = YPImagePickerConfiguration.shared.icons.multipleSelectionIcon
        iconImageView.contentMode = .scaleAspectFit

        layer.cornerRadius = 17
        clipsToBounds = true
        isUserInteractionEnabled = true
    }
}
