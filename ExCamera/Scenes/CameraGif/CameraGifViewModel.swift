import Foundation
import RxSwift
import RxCocoa

final class CameraGifViewModel: ViewModelType {
    struct Input {
        let disposeBag: DisposeBag
        let refreshTrigger: Driver<Void>
//        let selectedURL: Driver<(url: URL, animated: Bool)>
    }
    struct Output {
        let gifs: Driver<[GifImageSource]>
        let audios: Driver<[AudioSource]>
    }

    private let navigator: CameraGifNavigator

    init(navigator: CameraGifNavigator) {
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let gifs = Observable.just(GifImageRepository().elements.map { GifImageSource(cgImages: $0.cgImages,
                                                                                      delays: $0.delays,
                                                                                      duration: $0.duration,
                                                                                      defaultFrame: $0.defaultFrame,
                                                                                      data: $0.data,
                                                                                      animation: $0.animation,
                                                                                      overlay: $0.overlay,
                                                                                      scene: $0.scene) })
        let audios = Observable.just(AudioRepository().elements.map { AudioSource(data: $0.data, fileURL: $0.fileURL) })

        input.refreshTrigger.asObservable()
            .withLatestFrom(gifs)
            .subscribe()
            .disposed(by: input.disposeBag)
        input.refreshTrigger.asObservable()
            .withLatestFrom(audios)
            .subscribe()
            .disposed(by: input.disposeBag)
//        input.selectedURL.asObservable()
//            .subscribe(onNext: { [weak self] in self?.navigator.toPlayer(url: $0.url, animated: $0.animated) })
//            .disposed(by: input.disposeBag)

        return Output(
            gifs: gifs.asDriver(onErrorDriveWith: .empty()),
            audios: audios.asDriver(onErrorDriveWith: .empty())
        )
    }
}
