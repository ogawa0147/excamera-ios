import UIKit
import DIKit

final class TopPageViewController: UITableViewController, FactoryMethodInjectable {
    struct Dependency {
        let resolver: AppResolver
        let viewModel: TopPageViewModel
    }

    static func makeInstance(dependency: Dependency) -> TopPageViewController {
        let viewController = StoryboardScene.TopPageViewController.topPageViewController.instantiate()
        viewController.dependency = dependency
        return viewController
    }

    private var dependency: Dependency!
    private let dataSource = TopPageDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Top"
        dependency.viewModel.authorizationFromPhotoLibrary { _ in }
        dataSource.items = dependency.viewModel.sections
        tableView.tableFooterView = UIView()
        tableView.register(TopPageCell.self, forCellReuseIdentifier: "TopPageCell")
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dependency.viewModel.toPage(indexPath: indexPath)
    }
}
