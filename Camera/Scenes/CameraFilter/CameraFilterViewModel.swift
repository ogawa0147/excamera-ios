import Foundation
import DIKit

final class CameraFilterViewModel: Injectable {
    struct Dependency {
        let navigator: CameraFilterNavigator
    }

    private let dependency: Dependency

    let filters: [FilterSource]
    let audios: [AudioSource]

    init(dependency: Dependency) {
        let filters = FilterRepository().elements.map { FilterSource(filter: $0.filter, type: $0.type) }
        let audios = AudioRepository().elements.map { AudioSource(data: $0.data, fileURL: $0.fileURL) }

        self.dependency = dependency
        self.filters = filters
        self.audios = audios
    }

    func toPlayer(url: URL, animated: Bool = true) {
        dependency.navigator.toPlayer(url: url, animated: animated)
    }
}
