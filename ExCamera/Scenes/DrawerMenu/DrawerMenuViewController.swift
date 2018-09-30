import UIKit

// swiftlint:disable class_delegate_protocol
protocol DrawerMenuDelegate {
    func tableViewSelectedItem(at indexPath: IndexPath)
    func tableViewDeselectItem(at indexPath: IndexPath)
    func openedRightView()
    func closedRightView()
}

// MARK: protocol optional

extension DrawerMenuDelegate {
    func tableViewSelectedItem(at indexPath: IndexPath) {}
    func tableViewDeselectItem(at indexPath: IndexPath) {}
    func openedRightView() {}
    func closedRightView() {}
}

class DrawerMenuViewController: UITableViewController {

    // swiftlint:disable weak_delegate
    var delegate: DrawerMenuDelegate?

    var isOpenRight: Bool = false

    let dataSource: DrawerMenuItemDataSource = DrawerMenuItemDataSource()

    private let rightViewOptions: RightViewOptions = RightViewOptions()

    struct RightViewOptions {
        let duration: TimeInterval = 0.4
        let rect: CGRect = CGRect(x: UIScreen.main.bounds.maxX,
                                  y: UIScreen.main.bounds.minY,
                                  width: 150,
                                  height: UIScreen.main.bounds.maxY)
        func openedPositionX() -> CGFloat {
            return UIScreen.main.bounds.maxX - rect.size.width
        }
        func closedPositionX() -> CGFloat {
            return UIScreen.main.bounds.maxX
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = rightViewOptions.rect
        configureTableView()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableViewSelectedItem(at: indexPath)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        delegate?.tableViewDeselectItem(at: indexPath)
    }
}

// MARK: private functions

extension DrawerMenuViewController {
    private func configureTableView() {
        tableView.register(DrawerMenuItemCell.self, forCellReuseIdentifier: "DrawerMenuItemCell")
        tableView.dataSource = dataSource
        tableView.tableFooterView = UIView()
    }
}

// MARK: DrawerMenu actions

extension DrawerMenuViewController {
    public func openRight() {
        isOpenRight.toggle()
        UIView.animate(withDuration: rightViewOptions.duration, delay: 0.0, options: [], animations: { [weak self] () -> Void in
            guard let `self` = self else { return }
            self.view.frame.origin.x = self.rightViewOptions.openedPositionX()
            self.delegate?.openedRightView()
        })
    }
    public func closeRight() {
        isOpenRight.toggle()
        UIView.animate(withDuration: rightViewOptions.duration, delay: 0.0, options: [], animations: { [weak self] () -> Void in
            guard let `self` = self else { return }
            self.view.frame.origin.x = self.rightViewOptions.closedPositionX()
            self.delegate?.closedRightView()
        })
    }
}
