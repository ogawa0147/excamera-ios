import UIKit
import Cartography

class WallPaperGifCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }

    private func addSubviews() {
        addSubview(imageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        constrain(imageView) {
            $0.edges == $0.superview!.edges
        }
        layer.cornerRadius = min(frame.width, frame.height) * 0.1
        layer.masksToBounds = true
        backgroundColor = .lightGray
    }

    func bind(_ source: GifImageSource) {
        imageView.image = UIImage.gif(data: source.data)
        layoutIfNeeded()
    }
}
