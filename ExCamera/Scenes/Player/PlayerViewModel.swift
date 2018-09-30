import Foundation

final class PlayerViewModel {
    private let navigator: PlayerNavigator
    let url: URL

    init(navigator: PlayerNavigator, url: URL) {
        self.navigator = navigator
        self.url = url
    }
}
