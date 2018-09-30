import UIKit

final class GifAnimationOverlay: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(duration: CFTimeInterval, cgImages: [CGImage], defaultFrame: CGRect, animation: CAKeyframeAnimation) {
        super.init(frame: defaultFrame)
        self.isUserInteractionEnabled = true
        self.layer.bounds = defaultFrame
        self.layer.masksToBounds = true
        self.layer.contentsGravity = .resizeAspect
        self.layer.position = CGPoint(x: 0, y: 0)
        self.layer.add(animation, forKey: nil)
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(type(of: self).panGesture(_:))))
    }

    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            recognizer.setTranslation(center, in: superview)
        case .changed:
            center = recognizer.translation(in: superview)
        default:
            break
        }
    }
}
