import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class TopPageDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
    typealias Element = [TopPageViewModel.Section]
    var items: Element = []

    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].elements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TopPageCell", for: indexPath) as? TopPageCell else {
            fatalError()
        }
        cell.titleLabel.text = items[indexPath.section].title
        cell.accessoryType =  items[indexPath.section].elements[indexPath.row].accessoryType
        return cell
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        guard case .next(let newItems) = observedEvent else {
            return
        }
        items = newItems
        tableView.reloadData()
    }
}
