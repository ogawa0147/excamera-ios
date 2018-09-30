import UIKit
import RxSwift

class TopPageViewController: UITableViewController {
    var viewModel: TopPageViewModel!

    private let disposeBag = DisposeBag()
    private let dataSource = TopPageDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Top"
        configureTableView()
        bindViewModel()
    }

    private func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(TopPageCell.self, forCellReuseIdentifier: "TopPageCell")
    }

    private func bindViewModel() {
        let input = TopPageViewModel.Input(
            disposeBag: disposeBag,
            refreshTrigger: rx.viewWillAppear.take(1).asDriver(onErrorDriveWith: .empty()),
            itemSelected: tableView.rx.itemSelected.asDriver(onErrorDriveWith: .empty())
        )
        let output = viewModel.transform(input: input)
        output.sections
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        output.authorization
            .drive(onNext: { authorized in
                if authorized {}
            })
            .disposed(by: disposeBag)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
