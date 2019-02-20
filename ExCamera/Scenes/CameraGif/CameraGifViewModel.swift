import Foundation
import DIKit

final class CameraGifViewModel: Injectable {
    struct Dependency {
        let navigator: CameraGifNavigator
    }

    private let dependency: Dependency

    let gifs: [GifImageSource]
    let audios: [AudioSource]

    init(dependency: Dependency) {
        let gifs = GifImageRepository().elements.map { GifImageSource(cgImages: $0.cgImages, delays: $0.delays, duration: $0.duration, defaultFrame: $0.defaultFrame, data: $0.data, animation: $0.animation, overlay: $0.overlay, scene: $0.scene) }
        let audios = AudioRepository().elements.map { AudioSource(data: $0.data, fileURL: $0.fileURL) }
        self.dependency = dependency
        self.gifs = gifs
        self.audios = audios
    }

    func toPlayer(url: URL, animated: Bool = true) {
        dependency.navigator.toPlayer(url: url, animated: animated)
    }
}
