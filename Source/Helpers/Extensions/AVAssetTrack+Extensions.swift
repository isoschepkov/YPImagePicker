//
//  AVAssetTrack+Extensions.swift
//  YPImagePicker
//
//  Created by Nik Kov on 16.05.2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import AVFoundation

extension AVAssetTrack {
    func getTransform(cropRect: CGRect) -> CGAffineTransform {
        let renderSize = cropRect.size
        let renderScale = renderSize.width / cropRect.width
        let offset = CGPoint(x: -cropRect.origin.x, y: -cropRect.origin.y)
        let rotation = atan2(preferredTransform.b, preferredTransform.a)

        var rotationOffset = CGPoint(x: 0, y: 0)

        if preferredTransform.b == -1.0 {
            rotationOffset.y = naturalSize.width
        } else if preferredTransform.c == -1.0 {
            rotationOffset.x = naturalSize.height
        } else if preferredTransform.a == -1.0 {
            rotationOffset.x = naturalSize.width
            rotationOffset.y = naturalSize.height
        }

        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: renderScale, y: renderScale)
        transform = transform.translatedBy(x: offset.x + rotationOffset.x, y: offset.y + rotationOffset.y)
        transform = transform.rotated(by: rotation)
        return transform
    }
}
