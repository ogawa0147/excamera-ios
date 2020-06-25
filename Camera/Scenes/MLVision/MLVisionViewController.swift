import UIKit
import DIKit
import Firebase

final class MLVisionViewController: UIViewController, FactoryMethodInjectable {
    struct Dependency {
        let resolver: AppResolver
        let viewModel: MLVisionViewModel
    }

    static func makeInstance(dependency: Dependency) -> MLVisionViewController {
        let viewController = StoryboardScene.MLVisionViewController.mlVisionViewController.instantiate()
        viewController.dependency = dependency
        return viewController
    }

    private var dependency: Dependency!

    private lazy var vision = Vision.vision()
    private lazy var textRecognizer = vision.onDeviceTextRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
