import UIKit

public extension UIColor {
    struct Literal {
        private init() {}

        /** #00A99D */
        public static let theme = #colorLiteral(red: 0, green: 0.6745098039, blue: 0.6156862745, alpha: 1)
    }

    static func themeColor() -> UIColor {
        return UIColor(red: 246/255, green: 77/255, blue: 126/255, alpha: 1)
    }
}
