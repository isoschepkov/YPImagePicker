//
//  YPAlbumsNavigationController.swift
//  Motify
//
//  Created by Semyon Baryshev on 8/8/19.
//  Copyright © 2019 Heads and Hands. All rights reserved.
//

import UIKit

public class YPAlbumsNavigationController: UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return YPImagePickerConfiguration.shared.preferredStatusBarStyle
    }
}
