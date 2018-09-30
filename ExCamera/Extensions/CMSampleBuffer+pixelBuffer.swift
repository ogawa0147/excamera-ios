import Foundation
import AVFoundation

extension CMSampleBuffer {
    var pixelBuffer: CVPixelBuffer? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(self) else {
            return nil
        }
        let opaqueBuffer = Unmanaged<CVImageBuffer>.passUnretained(imageBuffer).toOpaque()
        return Unmanaged<CVPixelBuffer>.fromOpaque(opaqueBuffer).takeUnretainedValue()
    }
}
