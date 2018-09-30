import UIKit

class TopPageViewController: UITableViewController {
    var viewModel: TopPageViewModel!

    private let dataSource = TopPageDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Top"
        viewModel.authorizationFromPhotoLibrary { _ in }
        dataSource.items = viewModel.sections
        tableView.tableFooterView = UIView()
        tableView.register(TopPageCell.self, forCellReuseIdentifier: "TopPageCell")
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.toPage(indexPath: indexPath)
    }
}
