import Foundation
import DIKit

final class CameraEffectViewModel: Injectable {
    struct Dependency {
        let navigator: CameraEffectNavigator
    }

    private let dependency: Dependency

    let effects: [EffectViewSource]
    let audios: [AudioSource]

    init(dependency: Dependency) {
        let effects = EffectViewRepository().elements.map { EffectViewSource(effectStyle: $0.effectStyle, blurEffectView: $0.blurEffectView, vibrancyView: $0.vibrancyView) }
        let audios = AudioRepository().elements.map { AudioSource(data: $0.data, fileURL: $0.fileURL) }

        self.dependency = dependency
        self.effects = effects
        self.audios = audios
    }

    func toPlayer(url: URL, animated: Bool = true) {
        dependency.navigator.toPlayer(url: url, animated: animated)
    }
}
