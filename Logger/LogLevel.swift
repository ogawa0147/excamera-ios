import UIKit

enum LogLevel: Int {
    case debug
    case info
    case warning
    case error
}

extension LogLevel {
    var prefix: String {
        switch self {
        case .debug:   return "◽️"
        case .info:    return "🔷"
        case .warning: return "⚠️"
        case .error:   return "❌"
        }
    }
    var color: UIColor {
        switch self {
        case .debug:   return UIColor.lightGray
        case .info:    return UIColor.cyan
        case .warning: return UIColor.yellow
        case .error:   return UIColor.red
        }
    }
}
