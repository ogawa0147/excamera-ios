import Foundation

final class CameraVisionViewModel {
    private let navigator: CameraVisionNavigator
    let visions: [VisionDetectSource]
    let audios: [AudioSource]

    init(navigator: CameraVisionNavigator) {
        let visions = VisionDetectRepository().elements.map { VisionDetectSource(object: $0.object, type: $0.type) }
        let audios = AudioRepository().elements.map { AudioSource(data: $0.data, fileURL: $0.fileURL) }

        self.navigator = navigator
        self.visions = visions
        self.audios = audios
    }

    func toPlayer(url: URL, animated: Bool = true) {
        navigator.toPlayer(url: url, animated: animated)
    }
}
