import Foundation
import AVFoundation

final class AudioDevice {
    let device: AVCaptureDevice
    let input: AVCaptureDeviceInput

    init() {
        guard let device = AVCaptureDevice.default(for: .audio) else {
            fatalError()
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            fatalError()
        }

        self.device = device
        self.input = input
    }
}
