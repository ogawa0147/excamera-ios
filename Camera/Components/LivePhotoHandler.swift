import AVFoundation

final class LivePhotoHandler: NSObject {
    private let session: AVCaptureSession = AVCaptureSession()
    private let photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private let videoOrientation: AVCaptureVideoOrientation = .portrait

    var finishLivePhotoHandler: ((URL, CMTime, CMTime) -> Void)?

    func configureSession() {
        session.beginConfiguration()

        session.sessionPreset = .photo

        session.inputs.forEach { session.removeInput($0) }

        let videoDevice = VideoDevice(devicePosition: .front)
        let audioDevice = AudioDevice()
        session.addInput(videoDevice.input)
        session.addInput(audioDevice.input)

        session.outputs.forEach { session.removeOutput($0) }

        session.addOutput(photoOutput)

        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
        for connection in photoOutput.connections where connection.isVideoOrientationSupported {
            connection.videoOrientation = videoOrientation
            connection.isVideoMirrored = true
        }

        session.commitConfiguration()
    }

    func startSession() {
        session.startRunning()
    }

    func stopSession() {
        session.stopRunning()
    }

    func capture() {
        if let connection = photoOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
        }
        let settings = configurePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private func configurePhotoSettings() -> AVCapturePhotoSettings {
        var settings = AVCapturePhotoSettings()

        if photoOutput.availablePhotoCodecTypes.contains(AVVideoCodecType(rawValue: AVVideoCodecType.hevc.rawValue)) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        }

        // Specifies whether photos should be captured at the highest resolution supported by the source AVCaptureDevice's activeFormat.
        settings.isHighResolutionPhotoEnabled = false

        if !settings.availablePreviewPhotoPixelFormatTypes.isEmpty {
            // A dictionary of Core Video pixel buffer attributes specifying the preview photo format to be delivered along with the RAW or processed photo.
            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: settings.availablePreviewPhotoPixelFormatTypes.first!]
        }

        if photoOutput.isLivePhotoCaptureSupported {
            let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            let fileName = UUID().uuidString
            let fileURL = URL(fileURLWithPath: cachePath).appendingPathComponent("\(fileName).mov")
            // Specifies that a Live Photo movie be captured to complement the still photo.
            settings.livePhotoMovieFileURL = fileURL
        }

        // Specifies whether AVDepthData should be captured along with the photo.
        settings.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported

        return settings
    }
}

// MARK: AVCapturePhotoCaptureDelegate

extension LivePhotoHandler: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {}
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {}
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {}
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL, resolvedSettings: AVCaptureResolvedPhotoSettings) {}
    // swiftlint:disable function_parameter_count
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        guard error == nil else { return }
        finishLivePhotoHandler?(outputFileURL, duration, photoDisplayTime)
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {}
}
