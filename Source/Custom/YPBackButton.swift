//
//  YPBackButton.swift
//  Motify
//
//  Created by Semyon Baryshev on 5/23/19.
//  Copyright © 2019 Heads and Hands. All rights reserved.
//

import UIKit

class YPBackButton: UIView {
    var didTap: (() -> Void)?

    private let arrowImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true

        addSubview(arrowImageView)
        arrowImageView.frame = CGRect(x: 0, y: (frame.height - 16) / 2, width: 12, height: 20)
        arrowImageView.tintColor = YPImagePickerConfiguration.shared.colors.tintColor
        let tintedImage = YPImagePickerConfiguration.shared.icons.backButtonIcon.withRenderingMode(.alwaysTemplate)
        arrowImageView.image = tintedImage
        arrowImageView.contentMode = .scaleAspectFit
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func tap() {
        didTap?()
    }
}
