import Foundation
import AVFoundation
import MobileCoreServices
import ImageIO

final class LivePhotoWriter {
    private let kFigAppleMakerNoteAssetIdentifier: String = "17"
    private let kKeyStillImageTime: String = "com.apple.quicktime.still-image-time"

    private let kKeyContentIdentifier =  "com.apple.quicktime.content.identifier"
    private let kKeySpaceQuickTimeMetadata = "mdta"

    private let asset: AVURLAsset
    private let assetIdentifier: String
    private let imageOutputURL: URL
    private let videoOutputURL: URL

    init(sourceURL: URL) {
        self.assetIdentifier = UUID().uuidString
        self.asset = AVURLAsset(url: sourceURL)

        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        self.imageOutputURL = URL(fileURLWithPath: cachePath).appendingPathComponent("\(self.assetIdentifier).jpg")
        self.videoOutputURL = URL(fileURLWithPath: cachePath).appendingPathComponent("\(self.assetIdentifier).mov")
    }

    // swiftlint:disable function_body_length cyclomatic_complexity
    func write(_ completionHandler: @escaping (Bool, URL, URL) -> Void) {
        guard let imageData = generateDestinationImageData(asset: asset) else {
            completionHandler(false, imageOutputURL, videoOutputURL)
            return
        }
        writeImageData(imageData, at: imageOutputURL)

        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            completionHandler(false, imageOutputURL, videoOutputURL)
            return
        }
        let audioTrack = asset.tracks(withMediaType: .audio).first

        let writer = try? AVAssetWriter(outputURL: videoOutputURL, fileType: .mov)

        let assetIdentifierMetadataItem = metadataForAssetIdentifier(assetIdentifier)
        writer?.metadata = [assetIdentifierMetadataItem]

        let videoWriterInput = AVAssetWriterInput(mediaType: .video,
                                                  outputSettings: [AVVideoCodecKey: AVVideoCodecType.h264,
                                                                   AVVideoWidthKey: videoTrack.naturalSize.width,
                                                                   AVVideoHeightKey: videoTrack.naturalSize.height])
        videoWriterInput.expectsMediaDataInRealTime = true
        videoWriterInput.transform = videoTrack.preferredTransform
        writer?.add(videoWriterInput)

        var audioWriterInput: AVAssetWriterInput?
        var audioReaderTrackOutput: AVAssetReaderTrackOutput?
        var audioReader: AVAssetReader?
        if let audioTrack = audioTrack {
            audioReaderTrackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
            audioReader = try? AVAssetReader(asset: asset)
            audioReader!.add(audioReaderTrackOutput!)
            audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
            audioWriterInput!.expectsMediaDataInRealTime = false
        }
        if let audioWriterInput = audioWriterInput {
            writer?.add(audioWriterInput)
        }

        let adaptor = metadataAdaptor()
        writer?.add(adaptor.assetWriterInput)

        let videoReaderTrackOutput = AVAssetReaderTrackOutput(
            track: videoTrack,
            outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)]
        )

        let videoReader = try? AVAssetReader(asset: asset)
        videoReader?.add(videoReaderTrackOutput)

        videoReader?.startReading()
        audioReader?.startReading()
        writer?.startWriting()
        writer?.startSession(atSourceTime: .zero)

        let stillImageTimeMetadataItem = metadataForStillImageTime()
        adaptor.append(AVTimedMetadataGroup(items: [stillImageTimeMetadataItem],
                                            timeRange: CMTimeRangeMake(start: CMTimeMake(value: 0, timescale: 1000),
                                                                       duration: CMTimeMake(value: 200, timescale: 3000))))

        videoWriterInput.requestMediaDataWhenReady(on: DispatchQueue(label: "assetVideoWriterQueue", attributes: [])) {
            while videoWriterInput.isReadyForMoreMediaData {
                switch videoReader!.status {
                case .reading:
                    if let sampleBuffer = videoReaderTrackOutput.copyNextSampleBuffer() {
                        videoWriterInput.append(sampleBuffer)
                    }
                case .completed:
                    videoWriterInput.markAsFinished()
                    if audioTrack != nil {
                        audioReader?.startReading()
                        writer?.startSession(atSourceTime: .zero)
                        audioWriterInput?.requestMediaDataWhenReady(on: DispatchQueue(label: "assetAudioWriterQueue", attributes: [])) {
                            while audioWriterInput!.isReadyForMoreMediaData {
                                switch audioReader!.status {
                                case .reading:
                                    if let sampleBuffer = audioReaderTrackOutput?.copyNextSampleBuffer() {
                                        audioWriterInput?.append(sampleBuffer)
                                    }
                                case .completed:
                                    audioWriterInput?.markAsFinished()
                                    writer?.finishWriting {}
                                    completionHandler(true, self.imageOutputURL, self.videoOutputURL)
                                default:
                                    completionHandler(false, self.imageOutputURL, self.videoOutputURL)
                                }
                            }
                        }
                    } else {
                        writer?.finishWriting {}
                        completionHandler(true, self.imageOutputURL, self.videoOutputURL)
                    }
                default:
                    completionHandler(false, self.imageOutputURL, self.videoOutputURL)
                }
            }
        }
    }

    private func generateDestinationImageData(asset: AVAsset) -> Data? {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        guard let cgImage = try? generator.copyCGImage(at: .zero, actualTime: nil) else { return nil }

        let metadata = NSMutableDictionary()
        let makerNote = NSMutableDictionary()
        makerNote.setObject(assetIdentifier, forKey: kFigAppleMakerNoteAssetIdentifier as NSCopying)
        metadata.setObject(makerNote, forKey: (kCGImagePropertyMakerAppleDictionary as? NSCopying)!)

        let imageData = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(imageData, kUTTypeJPEG, 1, nil) else { return nil }
        CGImageDestinationAddImage(dest, cgImage, metadata)
        CGImageDestinationFinalize(dest)

        return imageData as Data
    }

    private func writeImageData(_ imageData: Data, at outputURL: URL) {
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(atPath: outputURL.path)
        }
        try? imageData.write(to: outputURL, options: [.atomic])
    }

    private func metadataAdaptor() -> AVAssetWriterInputMetadataAdaptor {
        let spec: NSDictionary = [
            kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier as NSString: "\(kKeySpaceQuickTimeMetadata)/\(kKeyStillImageTime)",
            kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType as NSString: "com.apple.metadata.datatype.int8"
        ]
        var desc: CMFormatDescription?
        CMMetadataFormatDescriptionCreateWithMetadataSpecifications(allocator: kCFAllocatorDefault,
                                                                    metadataType: kCMMetadataFormatType_Boxed,
                                                                    metadataSpecifications: [spec] as CFArray,
                                                                    formatDescriptionOut: &desc)
        let input = AVAssetWriterInput(mediaType: .metadata,
                                       outputSettings: nil,
                                       sourceFormatHint: desc)
        return AVAssetWriterInputMetadataAdaptor(assetWriterInput: input)
    }

    private func metadataForAssetIdentifier(_ assetIdentifier: String) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = kKeyContentIdentifier as (NSCopying & NSObjectProtocol)?
        item.keySpace = AVMetadataKeySpace(rawValue: kKeySpaceQuickTimeMetadata)
        item.value = assetIdentifier as (NSCopying & NSObjectProtocol)?
        item.dataType = "com.apple.metadata.datatype.UTF-8"
        return item
    }

    private func metadataForStillImageTime() -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = kKeyStillImageTime as (NSCopying & NSObjectProtocol)?
        item.keySpace = AVMetadataKeySpace(rawValue: kKeySpaceQuickTimeMetadata)
        item.value = 0 as (NSCopying & NSObjectProtocol)?
        item.dataType = "com.apple.metadata.datatype.int8"
        return item
    }
}
