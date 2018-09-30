import UIKit
import Photos

final class TopPageViewModel {
    private let navigator: TopPageNavigator
    let sections: [Section]

    struct Section {
        let title: String
        let elements: [Element]
    }
    struct Element {
        let accessoryType: UITableViewCell.AccessoryType
        fileprivate let action: (() -> Void)?
        init(accessoryType: UITableViewCell.AccessoryType = .none, action: (() -> Void)? = nil) {
            self.accessoryType = accessoryType
            self.action = action
        }
    }

    init(navigator: TopPageNavigator) {
        let sections = [
            Section(title: R.string.localizable.gifCameraTitle(), elements: [Element(action: navigator.toCameraGif)]),
            Section(title: R.string.localizable.effectCameraTitle(), elements: [Element(action: navigator.toCameraEffect)]),
            Section(title: R.string.localizable.filterCameraTitle(), elements: [Element(action: navigator.toCameraFilter)]),
            Section(title: R.string.localizable.visionCameraTitle(), elements: [Element(action: navigator.toCameraVision)]),
            Section(title: R.string.localizable.arCameraTitle(), elements: [Element(action: navigator.toARCamera)]),
            Section(title: R.string.localizable.wallPaperTitle(), elements: [Element(action: navigator.toWallPaper)])
        ]
        self.navigator = navigator
        self.sections = sections
    }

    func authorizationFromPhotoLibrary(_ completion: ((Bool) -> Void)?) {
        // 初回起動時に許可設定を促すダイアログが表示される
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
                completion?(status == .authorized)
            }
        }
    }

    func toPage(indexPath: IndexPath) {
        sections[indexPath.section].elements[indexPath.row].action?()
    }
}
