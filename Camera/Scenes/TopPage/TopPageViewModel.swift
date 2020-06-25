import UIKit
import Photos
import DIKit

final class TopPageViewModel: Injectable {
    struct Dependency {
        let navigator: TopPageNavigator
    }

    private let dependency: Dependency

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

    init(dependency: Dependency) {
        let sections = [
            Section(title: L10n.gifCameraTitle, elements: [Element(action: dependency.navigator.toCameraGif)]),
            Section(title: L10n.effectCameraTitle, elements: [Element(action: dependency.navigator.toCameraEffect)]),
            Section(title: L10n.filterCameraTitle, elements: [Element(action: dependency.navigator.toCameraFilter)]),
            Section(title: L10n.visionCameraTitle, elements: [Element(action: dependency.navigator.toCameraVision)]),
            Section(title: L10n.arCameraTitle, elements: [Element(action: dependency.navigator.toARCamera)]),
            Section(title: L10n.wallPaperTitle, elements: [Element(action: dependency.navigator.toWallPaper)]),
            Section(title: L10n.mlKitButtonTitle, elements: [Element(action: dependency.navigator.toMLVision)])
        ]
        self.dependency = dependency
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
