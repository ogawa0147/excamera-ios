import Foundation
import DIKit

final class WallPaperViewModel: Injectable {
    struct Dependency {
        let navigator: WallPaperNavigator
    }

    private let dependency: Dependency
    let gifs: [GifImageSource]

    init(dependency: Dependency) {
        let gifs = GifImageRepository().elements.map { GifImageSource(cgImages: $0.cgImages, delays: $0.delays, duration: $0.duration, defaultFrame: $0.defaultFrame, data: $0.data, animation: $0.animation, overlay: $0.overlay, scene: $0.scene) }

        self.dependency = dependency
        self.gifs = gifs
    }

    func toPlayer(url: URL, animated: Bool = true) {
        dependency.navigator.toPlayer(url: url, animated: animated)
    }
}
