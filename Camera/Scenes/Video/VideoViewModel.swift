import Foundation
import DIKit

final class VideoViewModel: Injectable {
    struct Dependency {
        let navigator: VideoNavigator
    }

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }
}
