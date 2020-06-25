import Foundation

public final class Constants {

    public static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    public struct GoogleService {
        public static var plistPath: String {
            return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
        }
        public static var contents: NSDictionary {
            return NSDictionary(contentsOfFile: plistPath)!
        }
    }
}
