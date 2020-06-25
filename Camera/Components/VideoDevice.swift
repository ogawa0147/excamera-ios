import Foundation
import AVFoundation

final class VideoDevice {
    let device: AVCaptureDevice
    let devicePosition: AVCaptureDevice.Position
    let input: AVCaptureDeviceInput

    init(devicePosition: AVCaptureDevice.Position, frameRate: CMTime) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: devicePosition) else {
            fatalError()
        }

        do {
            // カメラの設定を触るときはデバイスをロックする
            try device.lockForConfiguration()
        } catch let error {
            fatalError("failed: \(String(describing: error))")
        }

        // カメラにフレームレートを設定する
        device.activeVideoMaxFrameDuration = frameRate
        device.activeVideoMinFrameDuration = frameRate

        // フォーカスの設定 (画面の中心にオートフォーカス)
        if device.isFocusModeSupported(.autoFocus) && device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            device.focusMode = .autoFocus
        }

        // 露出の設定 （画面の中心に露出を合わせる）
        if device.isExposureModeSupported(.continuousAutoExposure) && device.isExposurePointOfInterestSupported {
            device.exposurePointOfInterest = CGPoint(x: 0.5, y: 0.5)
            device.exposureMode = .continuousAutoExposure
        }

        // 低照度で撮影する場合の明るさのブースト
        if device.isLowLightBoostEnabled {
            device.automaticallyEnablesLowLightBoostWhenAvailable = true
        }

        // ビデオHDRの設定
        if device.isVideoHDREnabled {
            device.isVideoHDREnabled = true
        }

        // デバイスのアンロック
        device.unlockForConfiguration()

        guard let input = try? AVCaptureDeviceInput(device: device) else {
            fatalError()
        }

        self.devicePosition = devicePosition
        self.device = device
        self.input = input
    }

    init(devicePosition: AVCaptureDevice.Position) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: devicePosition) else {
            fatalError()
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            fatalError()
        }
        self.devicePosition = devicePosition
        self.device = device
        self.input = input
    }
}
