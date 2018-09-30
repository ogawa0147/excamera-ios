import UIKit
import AVFoundation
import RxSwift
import Cartography

class CameraGifViewController: UIViewController {
    var viewModel: CameraGifViewModel!

    private let disposeBag = DisposeBag()

    private let dataSource: CameraGifDataSource = CameraGifDataSource()

    private let mp4Handler: MP4Handler = MP4Handler()

    private var mp4Writer: MP4Writer = MP4Writer()

    private var selectedItem: SelectedItem?
    struct SelectedItem {
        let indexPath: IndexPath
        let source: GifImageSource
    }

    lazy var captureView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .black
        view.isUserInteractionEnabled = true
        return view
    }()
    lazy var recordingButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = UIColor.themeColor()
        button.setTitle(R.string.localizable.recordingButtonTitle(), for: .normal)
        button.addTarget(self, action: #selector(type(of: self).doRecording), for: .touchUpInside)
        return button
    }()
    lazy var inOutCameraButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.tintColor = .white
        button.backgroundColor = UIColor.themeColor()
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.setImage(R.image.icon_inout_camera()?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.layer.cornerRadius = min(button.frame.width, button.frame.height) * 0.3
        button.layer.masksToBounds = true
        button.widthAnchor.constraint(equalToConstant: button.frame.size.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.frame.size.height).isActive = true
        button.addTarget(self, action: #selector(type(of: self).toggleInOutCamera), for: .touchUpInside)
        return button
    }()
    lazy var unsetSelectedItemButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.tintColor = .white
        button.backgroundColor = UIColor.lightGray
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.setImage(R.image.icon_trash()?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.layer.cornerRadius = min(button.frame.width, button.frame.height) * 0.3
        button.layer.masksToBounds = true
        button.widthAnchor.constraint(equalToConstant: button.frame.size.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.frame.size.height).isActive = true
        button.addTarget(self, action: #selector(type(of: self).unsetSelectedItem), for: .touchUpInside)
        return button
    }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.backgroundColor = .white
        view.showsHorizontalScrollIndicator = false
        view.register(CameraGifCell.self, forCellWithReuseIdentifier: "CameraGifCell")
        return view
    }()
    lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return layout
    }()
    lazy var progressBar: ProgressBarView = {
        let view = ProgressBarView(startColor: UIColor.lightGray, endColor: UIColor.themeColor(), duration: 5)
        return view
    }()
    lazy var countTimer: CountTimerView = {
        let view = CountTimerView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: inOutCameraButton),
                                              UIBarButtonItem(customView: unsetSelectedItemButton)]
        addSubview()
        configureCollectionView()
        bindViewModel()

        mp4Handler.configureSession()
        mp4Handler.captureOutputHandler = { (captureOutput, sampleBuffer) in
            guard CMSampleBufferDataIsReady(sampleBuffer), let pixelBuffer = sampleBuffer.pixelBuffer else {
                return
            }
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let uiImage = UIImage(ciImage: ciImage, scale: 1.0, orientation: .up)
            DispatchQueue.main.async {
                self.captureView.image = uiImage
            }
            self.mp4Writer.captureOutput(captureOutput: captureOutput, sampleBuffer: sampleBuffer, pixelBuffer: uiImage.pixelBuffer)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mp4Handler.startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mp4Handler.stopSession()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        constrain(collectionView) {
            $0.leading == $0.superview!.leading
            $0.trailing == $0.superview!.trailing
            $0.bottom == $0.superview!.bottom
            $0.width == $0.superview!.width
            $0.height == 80
        }
        constrain(captureView, collectionView) {
            $0.leading == $0.superview!.leading
            $0.trailing == $0.superview!.trailing
            $0.top == $0.superview!.top
            $0.bottom == $1.top
            $0.width == $0.superview!.width
        }
        constrain(recordingButton, collectionView) {
            $0.centerX == $0.superview!.centerX
            $0.bottom == $1.top - 10
            $0.width == 120
            $0.height == 120
        }
        constrain(progressBar, collectionView) {
            $0.left == $0.superview!.left + 5
            $0.right == $0.superview!.right - 5
            $0.bottom == $1.top - 3
            $0.height == 3
        }
        constrain(countTimer, captureView) {
            $0.centerY == $1.centerY
            $0.centerX == $1.centerX
            $0.width == 200
            $0.height == 200
        }
        recordingButton.layer.cornerRadius = min(recordingButton.frame.width, recordingButton.frame.height) * 0.5
        recordingButton.layer.masksToBounds = true
    }

    private func addSubview() {
        view.addSubview(captureView)
        view.addSubview(progressBar)
        view.addSubview(countTimer)
        view.addSubview(recordingButton)
        view.addSubview(collectionView)
    }

    private func configureCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.reloadData()
    }

    private func bindViewModel() {
        let input = CameraGifViewModel.Input(
            disposeBag: disposeBag,
            refreshTrigger: rx.viewWillAppear.take(1).asDriver(onErrorDriveWith: .empty())
//            itemSelected: collectionView.rx.itemSelected.asDriver())
        )
        let output = viewModel.transform(input: input)
        output.gifs
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        output.audios
            .drive(onNext: { authorized in
                if authorized {}
            })
            .disposed(by: disposeBag)
    }
}

// MARK: selectors

extension CameraGifViewController {
    @objc func doRecording() {
        toggleByRecordingEventsAsDisable(true)
        countTimer.start(withTimeInterval: 3, reverse: true, stopped: recordVideo)
    }

    @objc func toggleInOutCamera() {
        toggleByRecordingEventsAsDisable(true)
        mp4Handler.toggleInOutCamera()
        UIView.transition(with: captureView, duration: 0.5, options: .transitionFlipFromLeft, animations: nil) { [weak self] _ in
            self?.toggleByRecordingEventsAsDisable(false)
        }
    }

    @objc func unsetSelectedItem() {
        selectedItem = nil
        captureView.subviews.forEach { $0.removeFromSuperview() }
    }
}

// MARK: private functions

extension CameraGifViewController {
    private func recordVideo() {
        var audioURL: URL = viewModel.audios[0].fileURL
        if let indexPath = selectedItem?.indexPath, viewModel.audios.indices.contains(indexPath.row) {
            audioURL = viewModel.audios[indexPath.row].fileURL
        }
        let videoOutputSize: CGSize = captureView.frame.size
        progressBar.animate()
        mp4Writer.startRecording(audioURL: audioURL, videoOutputSize: videoOutputSize) { (exportURL, videoURL) in
            DispatchQueue.main.async {
                self.toggleByRecordingEventsAsDisable(false)
                self.captureView.subviews.forEach { $0.removeFromSuperview() }
                self.progressBar.refresh()
            }
            _ = AssetExportHandler(
                exportURL: exportURL,
                frameRate: self.mp4Handler.frameRate,
                videoURL: videoURL,
                audioURL: audioURL,
                sourceType: self.selectedItem?.source
            ) { [weak self] _, url in
                DispatchQueue.main.async {
                    self?.viewModel.toPlayer(url: url, animated: false)
                    self?.selectedItem = nil
                }
            }
        }
    }
    private func toggleByRecordingEventsAsDisable(_ disable: Bool) {
        inOutCameraButton.isEnabled.toggle()
        inOutCameraButton.backgroundColor = disable ? .gray : UIColor.themeColor()
        unsetSelectedItemButton.isEnabled.toggle()
        unsetSelectedItemButton.backgroundColor = disable ? .gray : UIColor.themeColor()
        recordingButton.isEnabled.toggle()
        recordingButton.backgroundColor = disable ? .gray : UIColor.themeColor()
        collectionView.allowsSelection.toggle()
        collectionView.isScrollEnabled.toggle()
    }
}

// MARK: UICollectionViewDelegate

extension CameraGifViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let element = dataSource.items[indexPath.row]
        element.overlay.layer.position = CGPoint(x: captureView.frame.midX, y: captureView.frame.midY)
        captureView.addSubview(element.overlay)
        selectedItem = SelectedItem(indexPath: indexPath, source: element)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        captureView.subviews.forEach { $0.removeFromSuperview() }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension CameraGifViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70.0, height: 70.0)
    }
}
