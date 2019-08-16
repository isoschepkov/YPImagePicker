//
//  YPLibrary+LibraryChange.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 26/01/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import Photos
import UIKit

extension YPLibraryVC: PHPhotoLibraryChangeObserver {
    func registerForLibraryChanges() {
        PHPhotoLibrary.shared().register(self)
    }

    func unregisterForLibraryChanges() {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.delegate?.libraryDidChange()
            let fetchResult = self.mediaManager.fetchResult!
            let collectionChanges = changeInstance.changeDetails(for: fetchResult)
            if collectionChanges != nil {
                self.mediaManager.fetchResult = collectionChanges!.fetchResultAfterChanges
                let collectionView = self.v.collectionView!
                if !collectionChanges!.hasIncrementalChanges || collectionChanges!.hasMoves {
                    collectionView.reloadData()
                } else {
                    collectionView.performBatchUpdates({
                        let removedIndexes = collectionChanges!.removedIndexes
                        if (removedIndexes?.count ?? 0) != 0 {
                            collectionView.deleteItems(at: removedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                            if let removedIndexesUnwrapped = removedIndexes {
                                (removedIndexesUnwrapped as NSIndexSet).enumerate({ index, _ in
                                    if let positionIndex = self.selection.firstIndex(where: { $0.index == index }) {
                                        self.selection.remove(at: positionIndex)
                                    }
                                })
                            }
                        }
                        let insertedIndexes = collectionChanges!.insertedIndexes
                        if (insertedIndexes?.count ?? 0) != 0 {
                            collectionView.insertItems(at: insertedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                        }
                    }, completion: { finished in
                        if finished {
                            let changedIndexes = collectionChanges!.changedIndexes
                            if (changedIndexes?.count ?? 0) != 0 {
                                collectionView.reloadItems(at: changedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                            }
                            self.refreshSelection()
                        }
                    })
                }
                self.mediaManager.resetCachedAssets()
                self.updateStateForCount(self.mediaManager.fetchResult.count)
            }
        }
    }
}
