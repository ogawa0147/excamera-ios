import Foundation
import Photos

final class GifImageRepository {
    let elements: [Element]

    struct Element {
        let cgImages: [CGImage]
        let delays: [Double]
        let duration: CFTimeInterval
        let defaultFrame: CGRect
        let data: Data
        let animation: GifAnimation
        let overlay: GifAnimationOverlay
        let scene: GifAnimationScene
    }

    enum FileType {
        case jpeg
        case png
        case gif
        case bmp
    }

    init() {
        let items: [NSDataAsset] = {
            var dataAssets: [NSDataAsset] = []
            var number: Int = 1
            while let dataAsset = NSDataAsset(name: String(format: "image%02d", number)) {
                dataAssets.append(dataAsset)
                number += 1
            }
            return dataAssets
        }()
        let elements = items.map { asset -> Element in
            guard let imageSource = CGImageSourceCreateWithData(asset.data as CFData, nil) else {
                fatalError()
            }
            guard let fileType = (asset.data as NSData).toFileType(), fileType == .gif else {
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
            let defaultFrame = CGRect(origin: CGPoint(x: 0, y: 0),
                                      size: CGSize(width: mappedCGImages[0].width, height: mappedCGImages[0].height))
            let animation = GifAnimation(duration: duration, cgImages: mappedCGImages)
            let overlay = GifAnimationOverlay(duration: duration, cgImages: mappedCGImages, defaultFrame: defaultFrame, animation: animation)
            let scene = GifAnimationScene(defaultFrame: defaultFrame, animation: animation)

            return Element(cgImages: mappedCGImages, delays: delays, duration: duration, defaultFrame: defaultFrame, data: asset.data, animation: animation, overlay: overlay, scene: scene)
        }
        self.elements = elements
    }
}

private extension NSData {
    func toFileType() -> GifImageRepository.FileType? {
        var values = [UInt32](repeating: 0, count: 1)
        getBytes(&values, length: 1)
        switch values[0] {
        case 0xFF: return .jpeg
        case 0x89: return .png
        case 0x47: return .gif
        case 0x42: return .bmp
        default: return nil
        }
    }
}
