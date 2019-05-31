//
//  YPPagerMenu.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 24/01/2018.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit

final class YPPagerMenu: UIView {
    var didSetConstraints = false
    var menuItems = [YPMenuItem]()
    var lineViewContainer = YPLineContainerView()
    var menuItemsContainer = UIView()

    convenience init() {
        self.init(frame: .zero)
        backgroundColor = YPImagePickerConfiguration.shared.colors.bottomMenuBackground
        clipsToBounds = true
    }

    var separators = [UIView]()

    func setUpMenuItemsConstraints() {
        let menuItemWidth: CGFloat = UIScreen.main.bounds.width / CGFloat(menuItems.count)
        var previousMenuItem: YPMenuItem?

        sv(
            lineViewContainer,
            menuItemsContainer
        )

        layout(
            0,
            |lineViewContainer| ~~ 2,
            0,
            |menuItemsContainer|,
            0
        )

        for m in menuItems {
            menuItemsContainer.sv(
                m
            )

            m.fillVertically().steviaWidth(menuItemWidth)
            if let pm = previousMenuItem {
                pm - 0 - m
            } else {
                |m
            }

            previousMenuItem = m
        }
    }

    override func updateConstraints() {
        super.updateConstraints()
        if !didSetConstraints {
            setUpMenuItemsConstraints()
        }
        didSetConstraints = true
    }

    func refreshMenuItems() {
        didSetConstraints = false
        updateConstraints()
    }
}
