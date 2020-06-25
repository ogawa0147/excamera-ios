import UIKit

class DrawerMenuItemDataSource: NSObject, UITableViewDataSource {
    typealias Element = [DrawerMenuItem]
    var items: Element = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DrawerMenuItemCell", for: indexPath) as? DrawerMenuItemCell else {
            fatalError()
        }
        cell.titleLabel.text = items[indexPath.row].title
        return cell
    }
}
