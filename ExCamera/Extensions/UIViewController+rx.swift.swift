import UIKit
import RxSwift

extension Reactive where Base: UIViewController {
    var viewWillAppear: Observable<Void> {
        return sentMessage(#selector(base.viewWillAppear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }
    var viewDidAppear: Observable<Void> {
        return sentMessage(#selector(base.viewDidAppear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }
    var viewWillDisappear: Observable<Void> {
        return sentMessage(#selector(base.viewWillDisappear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }
    var viewDidDisappear: Observable<Void> {
        return sentMessage(#selector(base.viewDidDisappear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }
    var viewWillAppearInvoked: Observable<Void> {
        return methodInvoked(#selector(base.viewWillAppear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }
    var viewDidAppearInvoked: Observable<Void> {
        return methodInvoked(#selector(base.viewDidAppear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }
    var viewWillDisappearInvoked: Observable<Void> {
        return methodInvoked(#selector(base.viewWillDisappear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }
    var viewDidDisappearInvoked: Observable<Void> {
        return methodInvoked(#selector(base.viewDidDisappear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }
}
