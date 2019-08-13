//
//  YPVideoProcessor.swift
//  YPImagePicker
//
//  Created by Nik Kov on 13.09.2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import AVFoundation
import UIKit

/*
 This class contains all support and helper methods to process the videos
 */
class YPVideoProcessor {
    static private var exporter: AVAssetExportSession?
    static private var exporterProgressTimer: Timer?

    /// Creates an output path and removes the file in temp folder if existing
    ///
    /// - Parameters:
    ///   - temporaryFolder: Save to the temporary folder or somewhere else like documents folder
    ///   - suffix: the file name wothout extension
    static func makeVideoPathURL(temporaryFolder: Bool, fileName: String) -> URL {
        var outputURL: URL

        if temporaryFolder {
            let outputPath = "\(NSTemporaryDirectory())\(fileName).\(YPConfig.video.fileType.fileExtension)"
            outputURL = URL(fileURLWithPath: outputPath)
        } else {
            guard let documentsURL = FileManager
                .default
                .urls(for: .documentDirectory,
                      in: .userDomainMask).first else {
                print("YPVideoProcessor -> Can't get the documents directory URL")
                return URL(fileURLWithPath: "Error")
            }
            outputURL = documentsURL.appendingPathComponent("\(fileName).\(YPConfig.video.fileType.fileExtension)")
        }

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: outputURL.path) {
            do {
                try fileManager.removeItem(atPath: outputURL.path)
            } catch {
                print("YPVideoProcessor -> Can't remove the file for some reason.")
            }
        }

        return outputURL
    }

    /*
     Crops the video to square by video height from the top of the video.
     */
    static func cropToSquare(asset: AVAsset, completion: @escaping (_ outputURL: URL?) -> Void) {
        // output file
        let outputPath = makeVideoPathURL(temporaryFolder: true, fileName: "squaredVideoFromCamera")

        // input file
        let composition = AVMutableComposition()
        composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)

        // Prevent crash if tracks is empty
        if asset.tracks.isEmpty {
            return
        }

        // trim to max recording size
        var asset = asset
        let trimEnd: CMTime = asset.duration.seconds > YPConfig.video.recordingTimeLimit
            ? CMTime(seconds: YPConfig.video.recordingTimeLimit, preferredTimescale: 30)
            : asset.duration
        if let trimmedAsset = trim(asset: asset, start: CMTime.zero, end: trimEnd) {
            asset = trimmedAsset
        }

        // input clip
        let clipVideoTrack = asset.tracks(withMediaType: .video)[0]

        // make it square
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: CGFloat(clipVideoTrack.naturalSize.height), height: CGFloat(clipVideoTrack.naturalSize.height))
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)

        // rotate to potrait
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let t1 = CGAffineTransform(translationX: clipVideoTrack.naturalSize.height, y: -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) / 2)
        let t2: CGAffineTransform = t1.rotated(by: .pi / 2)
        let finalTransform: CGAffineTransform = t2
        transformer.setTransform(finalTransform, at: CMTime.zero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]

        // exporter
        exporter?.cancelExport()
        exporter = AVAssetExportSession(asset: asset, presetName: YPConfig.video.compression)
        exporter?.videoComposition = videoComposition
        exporter?.outputURL = outputPath
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.outputFileType = YPConfig.video.fileType

        YPConfig.video.onStartVideoProcessing?()

        exporterProgressTimer?.invalidate()
        exporterProgressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let exporterUnwrapped = exporter,
            exporterUnwrapped.status == .exporting else {
                return
            }
            YPConfig.video.onProgressVideoProcessing?(exporterUnwrapped.progress)
        }

        exporter?.exportAsynchronously {
            YPConfig.video.onFinishVideoProcessing?()
            exporterProgressTimer?.invalidate()
            if exporter?.status == .completed {
                DispatchQueue.main.async(execute: {
                    completion(outputPath)
                })
                return
            } else if exporter?.status == .failed {
                print("YPVideoProcessor -> Export of the video failed. Reason: \(String(describing: exporter?.error))")
            }
            completion(nil)
            return
        }
    }

    static func trim(asset: AVAsset, start: CMTime, end: CMTime) -> AVAsset? {
        let composition = AVMutableComposition()
        let duration = CMTimeSubtract(end, start)
        let timeRange = CMTimeRangeMake(start: start, duration: duration)

        do {
            for track in asset.tracks {
                let compositionTrack = composition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
                try compositionTrack?.insertTimeRange(timeRange, of: track, at: .zero)
            }
        } catch {
            return nil
        }

        return composition
    }
}
