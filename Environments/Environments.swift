import Foundation

public final class Environments {
    public static let shared = Environments()

    var enviroment: Environment = .production

    public enum Environment {
        case development
        case production
    }

    private init() {}

    public func setEnviroment(_ enviroment: Environment) {
        self.enviroment = enviroment
    }
}
