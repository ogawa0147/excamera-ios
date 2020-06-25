import Foundation
import DIKit

final class YoutubePlayerViewModel: Injectable {
    struct Dependency {
        let navigator: YoutubePlayerNavigator
    }

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }
}
