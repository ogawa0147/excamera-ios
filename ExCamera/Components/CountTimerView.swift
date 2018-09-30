import UIKit

class CountTimerView: UIView {
    var countTimer: Timer?

    lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        counterLabel.frame = bounds
    }

    private func setup() {
        backgroundColor = .clear
        isHidden = true
        addSubview(counterLabel)
    }

    func start(withTimeInterval interval: Int, reverse: Bool = false, stopped: @escaping () -> Void) {
        isHidden = false

        var counter: Int = reverse ? interval : 0
        if counter < 0 {
            counter = 0
        }

        countTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            func finish(timer: Timer) {
                self.isHidden = true
                timer.invalidate()
                stopped()
            }
            if reverse {
                counter -= 1
                if counter < 0 {
                    finish(timer: timer)
                    return
                }
            } else {
                counter += 1
                if counter > interval {
                    finish(timer: timer)
                    return
                }
            }
            self.counterLabel.text = String(counter)
            self.setNeedsLayout()
        }

        counterLabel.text = String(counter)
        setNeedsLayout()
    }
}
