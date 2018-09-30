import UIKit

final class EffectViewRepository {
    let elements: [Element]

    struct Element {
        let effectStyle: UIBlurEffect.Style
        let blurEffectView: UIVisualEffectView
        let vibrancyView: UIVisualEffectView
    }

    init() {
        let items: [UIBlurEffect.Style] = [.dark, .extraLight, .light]
        let elements = items.map { style -> Element in
            let effect = UIBlurEffect(style: style)
            let vibrancyEffect = UIVibrancyEffect(blurEffect: effect)
            let blurEffectView = UIVisualEffectView(effect: effect)
            let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            return Element(effectStyle: style, blurEffectView: blurEffectView, vibrancyView: vibrancyView)
        }
        self.elements = elements
    }
}
