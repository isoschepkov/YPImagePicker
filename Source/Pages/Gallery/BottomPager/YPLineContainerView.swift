//
//  YPLineContainerView.swift
//  Motify
//
//  Created by Semyon Baryshev on 5/23/19.
//  Copyright © 2019 Heads and Hands. All rights reserved.
//

import UIKit

class YPLineContainerView: UIView {
    var line = UIView()

    convenience init() {
        self.init(frame: .zero)
        backgroundColor = YPImagePickerConfiguration.shared.colors.bottomMenuBackground

        sv(
            line
        )

        line.fillVertically()
        let index = YPImagePickerConfiguration.shared.screens.index(
            of: YPImagePickerConfiguration.shared.startOnScreen
        ) ?? 0
        moveLineTo(index: index, animated: false)
        line.backgroundColor = YPImagePickerConfiguration.shared.colors.tintColor
    }

    func moveLineTo(index: Int, animated: Bool = true) {
        let menuItemWidth: CGFloat = UIScreen.main.bounds.width /
            CGFloat(YPImagePickerConfiguration.shared.screens.count)
        let leftMargin = menuItemWidth * CGFloat(index)
        let rightMargin = UIScreen.main.bounds.width
            - menuItemWidth * CGFloat(index + 1)

        line.steviaLeftConstraint?.isActive = false
        line.steviaRightConstraint?.isActive = false

        |-leftMargin - line - rightMargin-|

        if animated {
            UIView.animate(
                withDuration: 0.4,
                delay: 0.0,
                options: .curveEaseInOut,
                animations: { [weak self] in
                    self?.layoutIfNeeded()
                }
            )
        }
    }
}
