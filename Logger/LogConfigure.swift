import Foundation

public final class LogConfigure {
    public static let shared = LogConfigure()

    var isEnable: Bool = false

    private init() {}

    public func enable() {
        self.isEnable = true
    }

    public func disable() {
        self.isEnable = false
    }
}
