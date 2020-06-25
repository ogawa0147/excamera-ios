import Foundation
import DIKit

final class MLVisionViewModel: Injectable {
    struct Dependency {
        let navigator: MLVisionNavigator
    }

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }
}
