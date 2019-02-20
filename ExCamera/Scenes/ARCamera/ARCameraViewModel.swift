import Foundation
import DIKit

final class ARCameraViewModel: Injectable {
    struct Dependency {
        let navigator: ARCameraNavigator
    }

    private let dependency: Dependency

    let sections: [Section]

    struct Section {
        let elements: [Element]
    }

    init(dependency: Dependency) {
        let gifs = GifImageRepository().elements.map { GifImageSource(cgImages: $0.cgImages, delays: $0.delays, duration: $0.duration, defaultFrame: $0.defaultFrame, data: $0.data, animation: $0.animation, overlay: $0.overlay, scene: $0.scene) }
        let sections = [
            Section(elements: gifs.map { Section.Element.gif($0) })
        ]

        self.dependency = dependency
        self.sections = sections
    }
}

extension ARCameraViewModel.Section {
    enum Element {
        case gif(GifImageSource)
    }
}
