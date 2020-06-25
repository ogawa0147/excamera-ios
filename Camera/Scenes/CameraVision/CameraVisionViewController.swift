import UIKit
import AVFoundation
import Cartography
import DIKit

final class CameraVisionViewController: UIViewController, FactoryMethodInjectable {
    struct Dependency {
        let resolver: AppResolver
        let viewModel: CameraVisionViewModel
    }

    static func makeInstance(dependency: Dependency) -> CameraVisionViewController {
        let viewController = StoryboardScene.CameraVisionViewController.cameraVisionViewController.instantiate()
        viewController.dependency = dependency
        return viewController
    }

    private var dependency: Dependency!

    private let mp4Handler: MP4Handler = MP4Handler()

    private var mp4Writer: MP4Writer = MP4Writer()

    private var selectedItem: VisionDetectSource?

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
        button.setTitle(L10n.recordingButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(type(of: self).doRecording), for: .touchUpInside)
        return button
    }()
    lazy var inOutCameraButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.tintColor = .white
        button.backgroundColor = UIColor.themeColor()
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.setImage(Asset.Assets.iconInoutCamera.image.withRenderingMode(.alwaysTemplate), for: .normal)
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
        button.setImage(Asset.Assets.iconTrash.image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.layer.cornerRadius = min(button.frame.width, button.frame.height) * 0.3
        button.layer.masksToBounds = true
        button.widthAnchor.constraint(equalToConstant: button.frame.size.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.frame.size.height).isActive = true
        button.addTarget(self, action: #selector(type(of: self).unsetSelectedItem), for: .touchUpInside)
        return button
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
        view.addSubview(captureView)
        view.addSubview(progressBar)
        view.addSubview(countTimer)
        view.addSubview(recordingButton)

        selectedItem = dependency.viewModel.visions.first

        mp4Handler.configureSession()
        mp4Handler.captureOutputHandler = { (captureOutput, sampleBuffer) in
            guard CMSampleBufferDataIsReady(sampleBuffer), let pixelBuffer = sampleBuffer.pixelBuffer else {
                return
            }
            guard let detector = self.selectedItem?.object as? VisionDetectFace else {
                return
            }
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let uiImage = UIImage(ciImage: ciImage, scale: 1.0, orientation: .up)
            detector.highlightFaces(for: uiImage) { resultImage in
                DispatchQueue.main.async {
                    self.captureView.image = resultImage
                }
                self.mp4Writer.captureOutput(captureOutput: captureOutput, sampleBuffer: sampleBuffer, pixelBuffer: uiImage.pixelBuffer)
            }
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
        constrain(captureView) {
            $0.edges == $0.superview!.edges
        }
        constrain(recordingButton) {
            $0.centerX == $0.superview!.centerX
            $0.bottom == $0.superview!.bottom - 10
            $0.width == 120
            $0.height == 120
        }
        constrain(progressBar) {
            $0.left == $0.superview!.left + 5
            $0.right == $0.superview!.right - 5
            $0.bottom == $0.superview!.bottom - 3
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
}

// MARK: selectors

extension CameraVisionViewController {
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
        captureView.subviews.forEach { $0.removeFromSuperview() }
    }
}

// MARK: private functions

extension CameraVisionViewController {
    private func recordVideo() {
        let audioURL: URL = dependency.viewModel.audios[0].fileURL
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
                sourceType: self.selectedItem
            ) { [weak self] _, url in
                DispatchQueue.main.async {
                    self?.dependency.viewModel.toPlayer(url: url, animated: false)
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
    }
}
