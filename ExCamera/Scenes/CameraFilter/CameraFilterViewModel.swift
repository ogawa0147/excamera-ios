import Foundation

final class CameraFilterViewModel {
    private let navigator: CameraFilterNavigator
    let filters: [FilterSource]
    let audios: [AudioSource]

    init(navigator: CameraFilterNavigator) {
        let filters = FilterRepository().elements.map { FilterSource(filter: $0.filter, type: $0.type) }
        let audios = AudioRepository().elements.map { AudioSource(data: $0.data, fileURL: $0.fileURL) }

        self.navigator = navigator
        self.filters = filters
        self.audios = audios
    }

    func toPlayer(url: URL, animated: Bool = true) {
        navigator.toPlayer(url: url, animated: animated)
    }
}
