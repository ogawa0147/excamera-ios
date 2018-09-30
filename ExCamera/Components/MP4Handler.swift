import AVFoundation

final class MP4Handler: NSObject {
    private let session: AVCaptureSession = AVCaptureSession()
    private var devicePosition: AVCaptureDevice.Position = .front
    private var videoOrientation: AVCaptureVideoOrientation = .portrait
    let frameRate: CMTime = CMTimeMake(value: 1, timescale: 30)

    var captureOutputHandler: ((AVCaptureOutput, CMSampleBuffer) -> Void)?

    func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .high

        session.inputs.forEach { session.removeInput($0) }

        let videoDevice = VideoDevice(devicePosition: devicePosition, frameRate: frameRate)
        let audioDevice = AudioDevice()
        session.addInput(videoDevice.input)
        session.addInput(audioDevice.input)
        session.outputs.forEach { session.removeOutput($0) }

        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        session.addOutput(videoDataOutput)

        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .utility))
        for connection in videoDataOutput.connections where connection.isVideoOrientationSupported {
            connection.videoOrientation = videoOrientation
            connection.isVideoMirrored = devicePosition == .front
        }

        session.commitConfiguration()
    }

    func startSession() {
        session.startRunning()
    }

    func stopSession() {
        session.stopRunning()
    }

    func toggleInOutCamera() {
        devicePosition = devicePosition == .front ? .back : .front
        session.stopRunning()
        configureSession()
        session.startRunning()
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate

extension MP4Handler: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if captureOutput is AVCaptureVideoDataOutput, connection.isVideoOrientationSupported {
            connection.videoOrientation = videoOrientation
        }
        captureOutputHandler?(captureOutput, sampleBuffer)
    }
}
