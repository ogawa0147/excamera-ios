import UIKit
import Cartography

class DrawerMenuItemCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
    }

    func addSubviews() {
        addSubview(titleLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        constrain(titleLabel) {
            $0.leading == $0.superview!.leading + 10
            $0.trailing == $0.superview!.trailing
            $0.centerY == $0.superview!.centerY
        }
    }
}
