import Foundation
import XCGLogger

class FileLogger: AutoRotatingFileDestination {
    var writeToFile: URL?
}
