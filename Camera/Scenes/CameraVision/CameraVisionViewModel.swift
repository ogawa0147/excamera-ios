import Foundation
import DIKit

final class CameraVisionViewModel: Injectable {
    struct Dependency {
        let navigator: CameraVisionNavigator
    }

    private let dependency: Dependency

    let visions: [VisionDetectSource]
    let audios: [AudioSource]

    init(dependency: Dependency) {
        let visions = VisionDetectRepository().elements.map { VisionDetectSource(object: $0.object, type: $0.type) }
        let audios = AudioRepository().elements.map { AudioSource(data: $0.data, fileURL: $0.fileURL) }

        self.dependency = dependency
        self.visions = visions
        self.audios = audios
    }

    func toPlayer(url: URL, animated: Bool = true) {
        dependency.navigator.toPlayer(url: url, animated: animated)
    }
}
