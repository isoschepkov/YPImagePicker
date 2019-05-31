//
//  YPBottomPagerView.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 24/01/2018.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit

final class YPBottomPagerView: UIView {
    private enum Constants {
        static let pagerHeight: CGFloat = 44.0
    }

    var header = YPPagerMenu()
    var scrollView = UIScrollView()

    convenience init() {
        self.init(frame: .zero)
        backgroundColor = UIColor(red: 239 / 255, green: 238 / 255, blue: 237 / 255, alpha: 1)

        sv(
            scrollView,
            header
        )

        layout(
            0,
            |scrollView|,
            0,
            |header| ~~ Constants.pagerHeight
        )

        if #available(iOS 11.0, *) {
            header.Bottom == safeAreaLayoutGuide.Bottom
        } else {
            header.steviaBottom(0)
        }
        header.steviaHeightConstraint?.constant = YPConfig.hidesBottomBar ? 0 : Constants.pagerHeight

        clipsToBounds = false
        setupScrollView()
    }

    private func setupScrollView() {
        scrollView.clipsToBounds = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
    }
}
