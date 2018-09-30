import Foundation

final class ARCameraViewModel {
    private let navigator: ARCameraNavigator
    let sections: [Section]

    struct Section {
        let elements: [Element]
    }

    init(navigator: ARCameraNavigator) {
        let gifs = GifImageRepository().elements.map { GifImageSource(cgImages: $0.cgImages, delays: $0.delays, duration: $0.duration, defaultFrame: $0.defaultFrame, data: $0.data, animation: $0.animation, overlay: $0.overlay, scene: $0.scene) }
        let sections = [
            Section(elements: gifs.map { Section.Element.gif($0) })
        ]

        self.navigator = navigator
        self.sections = sections
    }
}

extension ARCameraViewModel.Section {
    enum Element {
        case gif(GifImageSource)
    }
}
