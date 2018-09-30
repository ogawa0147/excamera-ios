import Foundation

final class CameraEffectViewModel {
    private let navigator: CameraEffectNavigator
    let effects: [EffectViewSource]
    let audios: [AudioSource]

    init(navigator: CameraEffectNavigator) {
        let effects = EffectViewRepository().elements.map { EffectViewSource(effectStyle: $0.effectStyle, blurEffectView: $0.blurEffectView, vibrancyView: $0.vibrancyView) }
        let audios = AudioRepository().elements.map { AudioSource(data: $0.data, fileURL: $0.fileURL) }

        self.navigator = navigator
        self.effects = effects
        self.audios = audios
    }

    func toPlayer(url: URL, animated: Bool = true) {
        navigator.toPlayer(url: url, animated: animated)
    }
}
