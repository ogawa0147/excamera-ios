import Foundation
import AVFoundation

final class AssetExportHandler {
    // swiftlint:disable function_body_length
    init(exportURL: URL, frameRate: CMTime, videoURL: URL, audioURL: URL, sourceType: SourceType?, _ completion: @escaping (Bool, URL) -> Void) {
        let composition = AVMutableComposition()

        let videoAsset = AVURLAsset(url: videoURL, options: nil)
        let audioAsset = AVURLAsset(url: audioURL, options: nil)

        guard let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            fatalError()
        }
        guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            fatalError()
        }

        let videoRange = CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration)

        let videoTrack = videoAsset.tracks(withMediaType: .video)[0]
        let audioTrack = audioAsset.tracks(withMediaType: .audio)[0]

        if videoTrack.isPlayable && videoCompositionTrack.isPlayable {
            videoCompositionTrack.preferredTransform = videoTrack.preferredTransform
        }

        do {
            try videoCompositionTrack.insertTimeRange(videoRange, of: videoTrack, at: CMTime.zero)
            try audioCompositionTrack.insertTimeRange(videoRange, of: audioTrack, at: CMTime.zero)
        } catch {
            fatalError("composition track error: \(error.localizedDescription)")
        }

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
        layerInstruction.setTransform(composition.preferredTransform, at: CMTime.zero)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = videoRange
        instruction.layerInstructions = [layerInstruction]

        let videoLayer = CALayer()
        videoLayer.frame = CGRect(x: 0, y: 0, width: composition.naturalSize.width, height: composition.naturalSize.height)
        videoLayer.anchorPoint = CGPoint(x: 0, y: 0)
        videoLayer.position = CGPoint(x: 0, y: 0)

        let parentLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: composition.naturalSize.width, height: composition.naturalSize.height)
        parentLayer.anchorPoint = CGPoint(x: 0, y: 0)
        parentLayer.position = CGPoint(x: 0, y: 0)
        parentLayer.addSublayer(videoLayer)

        switch sourceType {
        case (let source as GifImageSource):
            let position = CGPoint(x: source.overlay.layer.position.x, y: composition.naturalSize.height - source.overlay.layer.position.y)
            source.overlay.layer.position = position
            videoLayer.addSublayer(source.overlay.layer)
        case (let source as EffectViewSource):
            videoLayer.addSublayer(source.blurEffectView.layer)
        default: break
        }

        let animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = composition.naturalSize
        videoComposition.instructions = [instruction]
        videoComposition.frameDuration = frameRate
        videoComposition.animationTool = animationTool

        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            fatalError()
        }
        exportSession.outputURL = exportURL
        exportSession.outputFileType = exportURL.pathExtension.toFileType()
        exportSession.videoComposition = videoComposition
        exportSession.timeRange = videoRange
        exportSession.exportAsynchronously {
            completion(exportSession.status == AVAssetExportSession.Status.completed, exportURL)
        }
    }
}

private extension String {
    func toFileType() -> AVFileType {
        switch self {
        case "mov": return .mov
        case "mp4": return .mp4
        default:
            fatalError()
        }
    }
}
