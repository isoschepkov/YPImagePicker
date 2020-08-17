//
//  YPCameraVC.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 25/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import AVFoundation
import Photos
import UIKit

public class YPCameraVC: UIViewController, UIGestureRecognizerDelegate, YPPermissionCheckable {
    weak var videoCaptureDelegate: YPVideoCaptureDelegate?
    weak var photoCaptureDelegate: YPPhotoCaptureDelegate?
    public var didCapturePhoto: ((UIImage) -> Void)?
    var photoCapture = newPhotoCapture()
    let v: YPCameraView!
    public override func loadView() { view = v }

    public required init() {
        v = YPCameraView(overlayView: YPConfig.overlayView, style: YPImagePickerConfiguration.shared.photoViewStyle)
        super.init(nibName: nil, bundle: nil)
        title = YPConfig.wordings.cameraTitle
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        v.flashButton.isHidden = true
        v.flashButton.addTarget(self, action: #selector(flashButtonTapped), for: .touchUpInside)
        v.shotButton.addTarget(self, action: #selector(shotButtonTapped), for: .touchUpInside)
        v.flipButton.addTarget(self, action: #selector(flipButtonTapped), for: .touchUpInside)

        // Focus
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(focusTapped(_:)))
        tapRecognizer.delegate = self
        v.previewViewContainer.addGestureRecognizer(tapRecognizer)

        // Remove navigation bar shadow
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    func start() {
        doAfterPermissionCheck { [weak self] in
            self?.videoCaptureDelegate?.willStartVideoCapture(completion: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                self?.startCamera()
            })
        }
    }

    func startCamera() {
        photoCapture.start(with: v.previewViewContainer, completion: {
            DispatchQueue.main.async {
                self.refreshFlashButton()
            }
        })
    }

    @objc
    func focusTapped(_ recognizer: UITapGestureRecognizer) {
        doAfterPermissionCheck { [weak self] in
            self?.focus(recognizer: recognizer)
        }
    }

    func focus(recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: v.previewViewContainer)

        // Focus the capture
        let viewsize = v.previewViewContainer.bounds.size
        let newPoint = CGPoint(x: point.x / viewsize.width, y: point.y / viewsize.height)
        photoCapture.focus(on: newPoint)

        // Animate focus view
        v.focusView.center = point
        YPHelper.configureFocusView(v.focusView)
        v.addSubview(v.focusView)
        YPHelper.animateFocusView(v.focusView)
    }

    func stopCamera(completion: (() -> Void)? = nil) {
        photoCapture.stopCamera(completion: completion)
    }

    @objc
    func flipButtonTapped() {
        doAfterPermissionCheck { [weak self] in
            self?.v.flipButton.isEnabled = false
            self?.v.shotButton.isEnabled = false
            self?.photoCapture.flipCamera { [weak self] in
                self?.refreshFlashButton()
                self?.v.flipButton.isEnabled = true
                self?.v.shotButton.isEnabled = true
            }
        }
    }

    @objc
    func shotButtonTapped() {
        doAfterPermissionCheck { [weak self] in
            self?.shoot()
        }
    }

    func shoot() {
        // Prevent from tapping multiple times in a row
        // causing a crash
        if !(photoCapture.hasInputs && photoCapture.session.isRunning) {
            return
        }

        v.shotButton.isEnabled = false

        photoCaptureDelegate?.willStartPhotoCapture()

        photoCapture.shoot { imageData in
            guard let unwrappedImageData = imageData,
                let shotImage = UIImage(data: unwrappedImageData) else {
                self.v.shotButton.isEnabled = true
                self.photoCaptureDelegate?.didCancelPhotoCapture()
                return
            }

            self.photoCapture.stopCamera()

            var image = shotImage.resetOrientation()
            // Crop the image if the output needs to be square.
            if YPConfig.onlySquareImagesFromCamera {
                image = self.crop(image, to: 1)
            } else if YPImagePickerConfiguration.shared.photoViewStyle == .fullScreen,
                      let previewAspectRation = (self.view as? YPCameraView)?.previewAspectRatio {
                image = self.crop(image, to: previewAspectRation)
            }

            image = image.resizedImageIfNeeded()

            DispatchQueue.main.async {
                self.didCapturePhoto?(image)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.v.shotButton.isEnabled = true
                    self.startCamera()
                }
            }
        }
    }

    func crop(_ image: UIImage, to aspectRatio: CGFloat) -> UIImage {
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        var aspectRatio = aspectRatio
        var imageWidth: CGFloat = image.size.width
        var imageHeight: CGFloat = image.size.height

        switch orientation {
        case .landscapeLeft, .landscapeRight:
            // Swap width and height if orientation is landscape
            aspectRatio = 1 / aspectRatio
        default:
            break
        }

        let currentAspectRatio = imageWidth / imageHeight

        let width: CGFloat
        let height: CGFloat

        if currentAspectRatio == aspectRatio {
            return image
        } else if currentAspectRatio < aspectRatio {
            width = imageWidth
            height = width / aspectRatio
        } else {
            height = imageHeight
            width = height * aspectRatio
        }

        let x = (imageWidth - width) / 2
        let y = (imageHeight - height) / 2

        let newSize = CGSize(width: width, height: height)

        let rect = CGRect(x: x, y: y, width: width, height: height)
        let imageRef = image.cgImage?.cropping(to: rect)
        return UIImage(cgImage: imageRef!, scale: 1.0, orientation: image.imageOrientation)
    }

    @objc
    func flashButtonTapped() {
        photoCapture.tryToggleFlash()
        refreshFlashButton()
    }

    func refreshFlashButton() {
        let flashImage = photoCapture.currentFlashMode.flashImage()
        v.flashButton.setImage(flashImage, for: .normal)
        v.flashButton.isHidden = !photoCapture.hasFlash
    }
}
