import UIKit
import Photos
import RxSwift
import RxCocoa

final class TopPageViewModel: ViewModelType {
    struct Input {
        let disposeBag: DisposeBag
        let refreshTrigger: Driver<Void>
        let itemSelected: Driver<IndexPath>
    }
    struct Output {
        let sections: Driver<[Section]>
        let authorization: Driver<Bool>
    }

    private let navigator: TopPageNavigator

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
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let sections = Observable.just(
            [
                Section(title: R.string.localizable.gifCameraTitle(), elements: [Element(action: navigator.toCameraGif)]),
                Section(title: R.string.localizable.effectCameraTitle(), elements: [Element(action: navigator.toCameraEffect)]),
                Section(title: R.string.localizable.filterCameraTitle(), elements: [Element(action: navigator.toCameraFilter)]),
                Section(title: R.string.localizable.visionCameraTitle(), elements: [Element(action: navigator.toCameraVision)]),
                Section(title: R.string.localizable.arCameraTitle(), elements: [Element(action: navigator.toARCamera)]),
                Section(title: R.string.localizable.wallPaperTitle(), elements: [Element(action: navigator.toWallPaper)])
            ]
        )
        let authorization = PHPhotoLibrary.rx.requestAuthorization().map { $0 == .authorized }

        input.refreshTrigger.asObservable()
            .withLatestFrom(sections)
            .subscribe()
            .disposed(by: input.disposeBag)
        input.refreshTrigger.asObservable()
            .withLatestFrom(authorization)
            .subscribe()
            .disposed(by: input.disposeBag)
        input.itemSelected.asObservable()
            .withLatestFrom(sections) { $1[$0.section].elements[$0.row] }
            .subscribe(onNext: { $0.action?() })
            .disposed(by: input.disposeBag)

        return Output(
            sections: sections.asDriver(onErrorDriveWith: .empty()),
            authorization: authorization.asDriver(onErrorDriveWith: .empty())
        )
    }
}
