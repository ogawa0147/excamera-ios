import Foundation

final class CameraGifViewModel {
    private let navigator: CameraGifNavigator
    let gifs: [GifImageSource]
    let audios: [AudioSource]

    init(navigator: CameraGifNavigator) {
        let gifs = GifImageRepository().elements.map { GifImageSource(cgImages: $0.cgImages, delays: $0.delays, duration: $0.duration, defaultFrame: $0.defaultFrame, data: $0.data, animation: $0.animation, overlay: $0.overlay, scene: $0.scene) }
        let audios = AudioRepository().elements.map { AudioSource(data: $0.data, fileURL: $0.fileURL) }
        self.navigator = navigator
        self.gifs = gifs
        self.audios = audios
    }

    func toPlayer(url: URL, animated: Bool = true) {
        navigator.toPlayer(url: url, animated: animated)
    }
}
