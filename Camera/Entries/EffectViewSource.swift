import UIKit

struct EffectViewSource: SourceType {
    let effectStyle: UIBlurEffect.Style
    let blurEffectView: UIVisualEffectView
    let vibrancyView: UIVisualEffectView

    init(effectStyle: UIBlurEffect.Style, blurEffectView: UIVisualEffectView, vibrancyView: UIVisualEffectView) {
        self.effectStyle = effectStyle
        self.blurEffectView = blurEffectView
        self.vibrancyView = vibrancyView
        self.blurEffectView.contentView.addSubview(self.vibrancyView)
    }
}
