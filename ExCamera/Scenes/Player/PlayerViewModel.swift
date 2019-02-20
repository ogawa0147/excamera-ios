import Foundation
import DIKit

final class PlayerViewModel: Injectable {
    struct Dependency {
        let navigator: PlayerNavigator
        let url: URL
    }

    private let dependency: Dependency
    let url: URL

    init(dependency: Dependency) {
        self.dependency = dependency
        self.url = dependency.url
    }
}
