import UIKit
import Cartography

final class TopPageCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubViews()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        constrain(titleLabel) {
            $0.height == 48 ~ .defaultHigh
            $0.leading == $0.superview!.leading + 8
            $0.top == $0.superview!.top + 8
            $0.bottom <= $0.superview!.bottom - 8
        }
    }

    private func addSubViews() {
        addSubview(titleLabel)
    }
}
