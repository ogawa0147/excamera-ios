import Foundation

final class WallPaperViewModel {
    private let navigator: WallPaperNavigator
    let gifs: [GifImageSource]

    init(navigator: WallPaperNavigator) {
        let gifs = GifImageRepository().elements.map { GifImageSource(cgImages: $0.cgImages, delays: $0.delays, duration: $0.duration, defaultFrame: $0.defaultFrame, data: $0.data, animation: $0.animation, overlay: $0.overlay, scene: $0.scene) }

        self.navigator = navigator
        self.gifs = gifs
    }

    func toPlayer(url: URL, animated: Bool = true) {
        navigator.toPlayer(url: url, animated: animated)
    }
}
