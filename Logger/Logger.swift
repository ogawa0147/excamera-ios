import UIKit
import Foundation

public class Logger {
    private static let shared = Logger()
    private let queue = DispatchQueue(label: "log.output.queue")

    private init() {}

    public static func debug(_ items: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        shared.output(items, level: .debug, file: file, function: function, line: line)
    }

    public static func info(_ items: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        shared.output(items, level: .info, file: file, function: function, line: line)
    }

    public static func warning(_ items: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        shared.output(items, level: .warning, file: file, function: function, line: line)
    }

    public static func error(_ items: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        shared.output(items, level: .error, file: file, function: function, line: line)
    }

    private func output(_ items: Any..., level: LogLevel, file: String?, function: String?, line: Int?) {
        guard LogConfigure.shared.isEnable else {
            return
        }
        guard let file = file, let function = function, let line = line, let fileName = file.components(separatedBy: "/").last else {
            return
        }

        let fileInfo = "\(fileName).\(function)[\(line)]"

        let content = (items.first as? [Any] ?? []).reduce("") { result, next -> String in
            return "\(result)\(result.count > 0 ? " " : "")\(next)"
        }

        let date = Date()

        Logger.shared.queue.async {
            var startIndex = 0
            var lenghtDate: Int?

            let output = NSMutableString()

            output.append("\(level.prefix) ")

            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            output.append("[\(formatter.string(from: date))] ")

            lenghtDate = output.length
            startIndex = output.length

            output.append("\(fileInfo) : \(content)")

            let attributed = NSMutableAttributedString(string: output as String)
            attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: output.length))

            if let dateLenght = lenghtDate {
                let dateRange = NSRange(location: 0, length: dateLenght)
                attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0, green: 0.6745098039, blue: 0.6156862745, alpha: 1), range: dateRange)
                attributed.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 12), range: dateRange)
            }

            let fileInfoRange = NSRange(location: startIndex, length: fileInfo.count)
            attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: fileInfoRange)
            attributed.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 12), range: fileInfoRange)

            print(output)
        }
    }
}
