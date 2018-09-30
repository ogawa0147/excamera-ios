import UIKit

final class GifAnimation: CAKeyframeAnimation {
    required override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(duration: CFTimeInterval, cgImages: [CGImage]) {
        super.init()
        self.keyPath = "contents"
        self.calculationMode = CAAnimationCalculationMode.discrete
        self.beginTime = 0.01
        self.duration = duration
        self.values = cgImages
        self.repeatCount = .infinity
        self.isRemovedOnCompletion = false
        self.fillMode = CAMediaTimingFillMode.both
    }
}
