import UIKit

struct GifImageSource: SourceType {
    let cgImages: [CGImage]
    let delays: [Double]
    let duration: CFTimeInterval
    let defaultFrame: CGRect
    let data: Data
    let animation: GifAnimation
    let overlay: GifAnimationOverlay
    let scene: GifAnimationScene
}
