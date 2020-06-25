import UIKit

class ProgressBarView: UIView {
    private let startColor: UIColor
    private let endColor: UIColor
    private let keyTimes: [NSNumber]

    override private init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect = CGRect.zero, startColor: UIColor, endColor: UIColor, duration: Double) {
        var keyTimes: [NSNumber] = []
        var number: Double = 1
        keyTimes.append(0)
        while number <= (duration * 2) {
            let time = NSNumber(value: number / 2)
            keyTimes.append(time)
            number += 1
        }
        self.startColor = startColor
        self.endColor = endColor
        self.keyTimes = keyTimes
        super.init(frame: frame)
        backgroundColor = startColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(frame.width, frame.height) * 0.5
        layer.masksToBounds = true
    }

    func animate() {
        let beginMaskPath = CGMutablePath()
        beginMaskPath.addRect(CGRect(x: 0, y: 0, width: 0, height: frame.height))

        let endMaskPath = CGMutablePath()
        endMaskPath.addRect(CGRect(x: 0, y: 0, width: frame.width, height: frame.height))

        let maskLayer = CAShapeLayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        maskLayer.path = beginMaskPath

        let linePath = CGMutablePath()
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addRect(CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        linePath.closeSubpath()

        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        shapeLayer.path = linePath
        shapeLayer.strokeColor = endColor.cgColor
        shapeLayer.lineWidth = frame.height
        shapeLayer.fillColor = endColor.cgColor

        let pathKeyFrame = CAKeyframeAnimation(keyPath: "path")
        pathKeyFrame.values = [beginMaskPath, endMaskPath]
        pathKeyFrame.keyTimes = keyTimes
        pathKeyFrame.duration = CFTimeInterval(keyTimes.count)
        pathKeyFrame.fillMode = CAMediaTimingFillMode.forwards
        pathKeyFrame.isRemovedOnCompletion = false
        maskLayer.add(pathKeyFrame, forKey: "path")

        shapeLayer.mask = maskLayer
        layer.addSublayer(shapeLayer)
    }

    func refresh() {
        let linePath = CGMutablePath()
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addRect(CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        linePath.closeSubpath()

        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        shapeLayer.path = linePath
        shapeLayer.strokeColor = startColor.cgColor
        shapeLayer.lineWidth = frame.height
        shapeLayer.fillColor = startColor.cgColor
        layer.addSublayer(shapeLayer)
    }
}
