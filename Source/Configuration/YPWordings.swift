//
//  YPWordings.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 12/03/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import Foundation

public struct YPWordings {
    public var permissionPopup = PermissionPopup()
    public var videoDurationPopup = VideoDurationPopup()

    public struct PermissionPopup {
        public var title = "Permission denied" // YPImagePickerPermissionDeniedPopupTitle
        public var message = "Please allow access" // YPImagePickerPermissionDeniedPopupMessage
        public var cancel = "Cancel" // YPImagePickerPermissionDeniedPopupCancel
        public var grantPermission = "Grant Permission" // YPImagePickerPermissionDeniedPopupGrantPermission
    }

    public struct VideoDurationPopup {
        public var title = "Video duration" // YPImagePickerVideoDurationTitle
        public var tooShortMessage = "The video must be at least %@ seconds" // YPImagePickerVideoTooShort
        public var tooLongMessage = "Pick a video less than %@ seconds long" // YPImagePickerVideoTooLong
    }

    public var ok = "Ok" // YPImagePickerOk
    public var done = "Done" // YPImagePickerDone
    public var cancel = "Cancel" // YPImagePickerCancel
    public var save = "Save" // YPImagePickerSave
    public var processing = "Processing.." // YPImagePickerProcessing
    public var trim = "Trim" // YPImagePickerTrim
    public var cover = "Cover" // YPImagePickerCover
    public var albumsTitle = "Albums" // YPImagePickerAlbums
    public var libraryTitle = "Library" // YPImagePickerLibrary
    public var cameraTitle = "Photo" // YPImagePickerPhoto
    public var videoTitle = "Video" // YPImagePickerVideo
    public var next = "Next" // YPImagePickerNext
    public var filter = "Filter" // YPImagePickerFilter
    public var crop = "Crop" // YPImagePickerCrop
    public var warningMaxItemsLimit = "The limit is %d photos or videos" // YPImagePickerWarningItemsLimit
}
