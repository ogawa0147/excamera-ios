import Foundation
import XCGLogger

// from https://github.com/DaveWoodCom/XCGLogger
public class Logger {
    static let shared = Logger()

    let logger: XCGLogger
    let fileLogger: FileLogger

    private init() {
        // from https://stackoverflow.com/questions/33528507/xcglogger-3-0-doesnt-write-logfile-to-filesystem-ios-9
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let writeToFile = cacheDirectory.appendingPathComponent("app")

        let fileLogger = FileLogger(writeToFile: writeToFile, identifier: "me.example.camera.logger")

        fileLogger.logQueue = XCGLogger.logQueue
        fileLogger.writeToFile = writeToFile

        self.logger = XCGLogger.default

        self.fileLogger = fileLogger
    }

    func setTargetMaxFileSize(_ number: UInt64) {
        fileLogger.targetMaxFileSize = number
    }

    func setTargetMaxLogFiles(_ number: UInt8) {
        fileLogger.targetMaxLogFiles = number
    }

    public var appLogs: [(fileName: String, filePath: String)] {
        guard let archiveFolderURL = fileLogger.archiveFolderURL, FileManager.default.fileExists(atPath: archiveFolderURL.path) else {
            return []
        }
        guard let items = try? FileManager.default.contentsOfDirectory(atPath: archiveFolderURL.path) else {
            return []
        }
        return items.sorted().map {
            let name = $0
            let url = (archiveFolderURL.path as NSString).appendingPathComponent($0)
            return (fileName: name, filePath: url)
        }
    }

    public var appCurrentLog: String {
        guard let currentRunningFileURL = fileLogger.writeToFile, FileManager.default.fileExists(atPath: currentRunningFileURL.path) else {
            return ""
        }
        guard let logText = try? String(contentsOfFile: currentRunningFileURL.path) else {
            return ""
        }
        return logText
    }

    public class func verbose(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        self.shared.logger.logln(.verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
    }

    public class func debug(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        self.shared.logger.logln(.debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
    }

    public class func info(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        self.shared.logger.logln(.info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
    }

    public class func warning(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        self.shared.logger.logln(.warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
    }

    public class func error(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        self.shared.logger.logln(.error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
    }

    public class func severe(_ closure: @autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        self.shared.logger.logln(.severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo, closure: closure)
    }
}
