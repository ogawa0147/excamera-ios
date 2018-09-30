import UIKit

extension Data {
    var animation: CAKeyframeAnimation {
        guard let imageSource = CGImageSourceCreateWithData(self as CFData, nil) else {
            fatalError()
        }
        guard (self as NSData).isGif() else {
            fatalError()
        }

        let sourceCount = CGImageSourceGetCount(imageSource)

        var cgImages: [CGImage?] = []
        (0..<sourceCount).forEach { cgImages.append(CGImageSourceCreateImageAtIndex(imageSource, $0, nil)) }

        var delays: [Double] = []
        (0..<sourceCount).forEach { index in
            var delay: Double = 0.1
            let cfProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil)
            let gifProperties = unsafeBitCast(CFDictionaryGetValue(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()), to: CFDictionary.self)
            var delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()), to: AnyObject.self)
            if delayObject.doubleValue == 0 {
                delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
            }
            delay = delayObject as? Double ?? 0
            if delay < 0.1 {
                delay = 0.1
            }
            delays.append(delay)
        }

        var duration: CFTimeInterval = 0.0
        delays.forEach { duration += CFTimeInterval($0) }

        let mappedCGImages = cgImages.compactMap { $0 }

        let animation = CAKeyframeAnimation(keyPath: "contents")
        animation.calculationMode = CAAnimationCalculationMode.discrete
        animation.beginTime = 0.01
        animation.duration = duration
        animation.values = mappedCGImages
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.both

        return animation
    }
}

private extension NSData {
    func isGif() -> Bool {
        var values = [UInt32](repeating: 0, count: 1)
        getBytes(&values, length: 1)
        return values[0] == 0x47
    }
}
