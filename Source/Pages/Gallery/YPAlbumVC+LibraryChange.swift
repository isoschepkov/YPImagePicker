//
//  YPAlbumVC+LibraryChange.swift
//  Motify
//
//  Created by Semyon Baryshev on 8/8/19.
//  Copyright © 2019 Heads and Hands. All rights reserved.
//

import Photos
import UIKit

extension YPAlbumVC: PHPhotoLibraryChangeObserver {
    func registerForLibraryChanges() {
        PHPhotoLibrary.shared().register(self)
    }

    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [weak self] in
            self?.albumsManager.resetCache()
            self?.fetchAlbumsInBackground()
        }
    }
}
