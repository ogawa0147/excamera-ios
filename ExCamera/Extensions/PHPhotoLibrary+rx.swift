import Foundation
import Photos
import RxSwift

extension Reactive where Base: PHPhotoLibrary {
    static func requestAuthorization() -> Single<PHAuthorizationStatus> {
        return .create { observer in
            let status = Base.authorizationStatus()
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async {
                        observer(.success(status))
                    }
                }
            default:
                observer(.success(status))
            }
            return Disposables.create()
        }
    }
}
