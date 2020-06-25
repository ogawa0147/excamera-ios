import UIKit
import AVFoundation
import Photos
import MobileCoreServices
import Cartography
import DIKit

final class WallPaperViewController: UIViewController, FactoryMethodInjectable {
    struct Dependency {
        let resolver: AppResolver
        let viewModel: WallPaperViewModel
    }

    static func makeInstance(dependency: Dependency) -> WallPaperViewController {
        let viewController = StoryboardScene.WallPaperViewController.wallPaperViewController.instantiate()
        viewController.dependency = dependency
        return viewController
    }

    private var dependency: Dependency!

    private let dataSource: WallPaperDataSource = WallPaperDataSource()

    private let livePhotoHandler: LivePhotoHandler = LivePhotoHandler()

    private var selectedImageSource: GifImageSource?

    lazy var picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeImage, kUTTypeLivePhoto] as [String]
        picker.delegate = self
        return picker
    }()
    lazy var captureView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.black
        return view
    }()
    lazy var creatingButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = UIColor.themeColor()
        button.setTitle(L10n.creatingButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(type(of: self).doCreating), for: .touchUpInside)
        return button
    }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.backgroundColor = .white
        view.showsHorizontalScrollIndicator = false
        view.register(WallPaperGifCell.self, forCellWithReuseIdentifier: "WallPaperGifCell")
        return view
    }()
    lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return layout
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(captureView)
        view.addSubview(collectionView)
        view.addSubview(creatingButton)

        livePhotoHandler.configureSession()

        if let source = dependency.viewModel.gifs.first {
            captureView.image = UIImage.gif(data: source.data)
            selectedImageSource = source
        }

        dataSource.items = dependency.viewModel.gifs

        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        livePhotoHandler.startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        livePhotoHandler.stopSession()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        constrain(captureView) {
            $0.leading == $0.superview!.leading
            $0.trailing == $0.superview!.trailing
            $0.top == $0.superview!.top
        }
        constrain(collectionView, captureView) {
            $0.leading == $0.superview!.leading
            $0.trailing == $0.superview!.trailing
            $0.top == $1.bottom
            $0.bottom == $0.superview!.bottom
            $0.width == $0.superview!.width
            $0.height == 80
        }
        constrain(creatingButton, collectionView) {
            $0.centerX == $0.superview!.centerX
            $0.bottom == $1.top - 10
            $0.width == 120
            $0.height == 120
        }
        creatingButton.layer.cornerRadius = min(creatingButton.frame.width, creatingButton.frame.height) * 0.5
        creatingButton.layer.masksToBounds = true
    }
}

extension WallPaperViewController {
    private func adjustVideoSize(_ size: CGSize) -> CGSize {
        var outputSize: CGSize = size
        if outputSize.width.truncatingRemainder(dividingBy: 2) != 0 {
            outputSize.width += 1
        }
        if outputSize.height.truncatingRemainder(dividingBy: 2) != 0 {
            outputSize.height += 1
        }
        return outputSize
    }
    private func writeMovieFile(cgImages: [CGImage], outputSize: CGSize, url: URL, duration: Int64) {
        var frameCount: Int64 = 0
        var frameTime: CMTime = .zero
        var second = CMTimeGetSeconds(.zero)

        let assetWriter = AssetWriter(outputURL: url, fileType: .mov, videoOutputSize: outputSize)!
        assetWriter.start(atSourceTime: .zero)

        finish: while true {
            if cgImages.isEmpty { break finish }
            if duration <= Int64(second) { break finish }
            for cgImage in cgImages {
                if !assetWriter.isReadyForMoreMediaData() { break finish }
                frameTime = CMTimeMake(value: frameCount * 5, timescale: 60)
                second = CMTimeGetSeconds(frameTime)

                let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
                let pixelBuffer = image.resize(size: outputSize)?.pixelBuffer
                assetWriter.appendToAdaptor(pixelBuffer: pixelBuffer!, withPresentationTime: frameTime)

                frameCount += 1

                if duration <= Int64(second) { break finish }
            }
        }

        assetWriter.finish(atSourceTime: frameTime) {}
    }
}

extension WallPaperViewController {
    @objc func doCreating() {
        livePhotoHandler.capture()
        livePhotoHandler.finishLivePhotoHandler = { [weak self] (_, duration, photoDisplayTime) in
            guard let self = self else { return }
            guard let imageSource = self.selectedImageSource else { return }
            let outputSize = self.adjustVideoSize(self.captureView.frame.size)
            let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            let sourceMovieURL = URL(fileURLWithPath: cachePath).appendingPathComponent("livephoto.mov")
            if FileManager.default.fileExists(atPath: sourceMovieURL.path) {
                try? FileManager.default.removeItem(atPath: sourceMovieURL.path)
            }
            let movieDuration = Int64(Float(duration.value) / Float(duration.timescale))
            self.writeMovieFile(cgImages: imageSource.cgImages, outputSize: outputSize, url: sourceMovieURL, duration: movieDuration)
            _ = LivePhotoWriter(sourceURL: sourceMovieURL).write { _, imageURL, videoURL in
                guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetCreationRequest.forAsset()
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = true
                    request.addResource(with: .photo, fileURL: imageURL, options: nil)
                    request.addResource(with: .pairedVideo, fileURL: videoURL, options: options)
                }, completionHandler: { success, error in
                    if !success {
                        fatalError(error!.localizedDescription)
                    }
                    DispatchQueue.main.async {
                        self.present(self.picker, animated: true, completion: nil)
                    }
                })
            }
        }
    }
}

// MARK: UICollectionViewDelegate

extension WallPaperViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageSource = dataSource.items[indexPath.row]
        DispatchQueue.main.async {
            self.captureView.image = UIImage.gif(data: imageSource.data)
        }
        selectedImageSource = imageSource
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension WallPaperViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70.0, height: 70.0)
    }
}

// MARK: UINavigationControllerDelegate, UIImagePickerControllerDelegate

extension WallPaperViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
