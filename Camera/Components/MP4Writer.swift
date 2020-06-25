import AVFoundation

final class MP4Writer {
    private var assetWriter: AssetWriter?

    private var recording: Bool = false
    private var recordingFrameCount: Int64 = 0
    private var startRecordingTime: CMTime = .zero
    private var finishRecordingTime: CMTime = .zero

    private let cacheURL: URL
    private let outputURL: URL

    init() {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]

        self.cacheURL = URL(fileURLWithPath: cachePath).appendingPathComponent("cache.mp4")
        self.outputURL = URL(fileURLWithPath: cachePath).appendingPathComponent("output.mp4")
    }

    func startRecording(audioURL: URL, videoOutputSize outputSize: CGSize, _ completion: @escaping (URL, URL) -> Void) {
        removeFile(fileURL: cacheURL)
        removeFile(fileURL: outputURL)

        recording.toggle()
        recordingFrameCount = 0
        startRecordingTime = .zero
        finishRecordingTime = .zero

        let videoOutputSize: CGSize = adjustVideoSize(outputSize)

        assetWriter = AssetWriter(outputURL: cacheURL, fileType: .mp4, videoOutputSize: videoOutputSize)
        assetWriter?.start(atSourceTime: CMTime.zero)

        let audioPlayer = AudioPlayer(audioURL: audioURL)
        audioPlayer.player.play()

        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { timer in
            timer.invalidate()
            audioPlayer.player.stop()
            self.recording.toggle()
            self.assetWriter?.finish(atSourceTime: self.finishRecordingTime) {
                completion(self.outputURL, self.cacheURL)
            }
        }
    }

    func captureOutput(captureOutput: AVCaptureOutput, sampleBuffer: CMSampleBuffer, pixelBuffer: CVPixelBuffer?) {
        guard recording, let assetWriter = assetWriter, assetWriter.isReadyForMoreMediaData(), let pixelBuffer = pixelBuffer else { return }
        if recordingFrameCount == 0 {
            startRecordingTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        }
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let frameTime = CMTimeSubtract(timestamp, startRecordingTime)
        if captureOutput is AVCaptureVideoDataOutput {
            assetWriter.appendToAdaptor(pixelBuffer: pixelBuffer, withPresentationTime: frameTime)
            recordingFrameCount += 1
        }
        finishRecordingTime = frameTime
    }

    private func adjustVideoSize(_ size: CGSize) -> CGSize {
        var outputSize: CGSize = size
        if outputSize.width.truncatingRemainder(dividingBy: 2) != 0 {
            outputSize.width += 1
        }
        if outputSize.height.truncatingRemainder(dividingBy: 2) != 0 {
            outputSize.height += 1
        }
        return outputSize
    }

    private func removeFile(fileURL: URL) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(atPath: fileURL.path)
        }
    }
}
