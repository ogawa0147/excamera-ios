import Foundation

public final class Constants {
    public static let shared = Constants()

    private var enviroment: Environment = .production

    public enum Environment {
        case development
        case production
    }

    private init() {}

    public func setEnviroment(_ enviroment: Environment) {
        self.enviroment = enviroment
    }

    public func configureLogger() {
        let fileLogger = Logger.shared.fileLogger
        let logger = Logger.shared

        switch enviroment {
        case .development:
            let targetMaxFileSize: UInt64 = 1024 * 1024 * 10 // 10 MB
            let targetMaxLogFiles: UInt8 = 10
            logger.setTargetMaxFileSize(targetMaxFileSize)
            logger.setTargetMaxLogFiles(targetMaxLogFiles)
            logger.logger.setup(level: .verbose, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, fileLevel: .verbose)
        case .production:
            logger.logger.setup(level: .info, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, fileLevel: .info)
        }

        [fileLogger].forEach { logger.logger.add(destination: $0) }
    }
}
