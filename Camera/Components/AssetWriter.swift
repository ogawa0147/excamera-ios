import Foundation
import AVFoundation

final class AssetWriter {
    private let writer: AVAssetWriter
    private let adaptor: AVAssetWriterInputPixelBufferAdaptor

    init?(outputURL: URL, fileType outputFileType: AVFileType = .mp4, videoOutputSize: CGSize) {
        guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: outputFileType) else { return nil }

        let input = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: videoOutputSize.width,
                AVVideoHeightKey: videoOutputSize.height
            ]
        )
        input.expectsMediaDataInRealTime = true
        writer.add(input)

        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        )

        self.writer = writer
        self.adaptor = adaptor
    }

    func start(atSourceTime startTime: CMTime) {
        writer.startWriting()
        writer.startSession(atSourceTime: startTime)
    }

    func finish(atSourceTime endTime: CMTime, completionHandler handler: @escaping () -> Void) {
        adaptor.assetWriterInput.markAsFinished()
        writer.endSession(atSourceTime: endTime)
        writer.finishWriting(completionHandler: handler)
    }

    func isReadyForMoreMediaData() -> Bool {
        return adaptor.assetWriterInput.isReadyForMoreMediaData
    }

    func appendToAdaptor(pixelBuffer: CVPixelBuffer, withPresentationTime presentationTime: CMTime) {
        adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
    }
}
