import UIKit

public protocol UITableViewCellNibRegistrable: class {
    static var reuseIdentifier: String { get }
    static var nib: UINib { get }
}

public extension UITableViewCellNibRegistrable {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
    public static var nib: UINib {
        let nibName = String(describing: self)
        return UINib(nibName: nibName, bundle: Bundle(for: self))
    }
}

public extension UITableView {
    public func register<T: UITableViewCellNibRegistrable>(_ registrableType: T.Type, forCellReuseIdentifier reuseIdentifier: String) where T: UITableViewCell {
        register(registrableType.nib, forCellReuseIdentifier: reuseIdentifier)
    }
}

public extension UITableView {
    public func dequeueReusableCell<T: UITableViewCellNibRegistrable>(withIdentifier identifier: String, for indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with type \(T.self)")
        }
        return cell
    }
}
