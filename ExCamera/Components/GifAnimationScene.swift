import ARKit

final class GifAnimationScene: UIView {
    var node: SCNNode!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(defaultFrame: CGRect, animation: CAKeyframeAnimation) {
        super.init(frame: defaultFrame)

        let layer = CALayer()
        layer.bounds = defaultFrame
        layer.backgroundColor = UIColor.clear.cgColor
        layer.add(animation, forKey: "contents")

        self.backgroundColor = UIColor.clear
        self.layer.bounds = CGRect(x: -defaultFrame.midX, y: -defaultFrame.midY, width: defaultFrame.size.width, height: defaultFrame.size.height)
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.layer.addSublayer(layer)

        let scale: CGFloat = 0.3
        let geometry = SCNPlane(width: defaultFrame.size.width * scale / defaultFrame.size.height, height: scale)
        geometry.firstMaterial?.isDoubleSided = true
        geometry.firstMaterial?.diffuse.contents = self.layer

        let node = SCNNode()
        node.geometry = geometry

        self.node = node
    }
}
