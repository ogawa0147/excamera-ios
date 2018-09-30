import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    var viewModel: PlayerViewModel!

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.tintColor = .white
        button.backgroundColor = UIColor.lightGray
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.setImage(R.image.icon_cancel()?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.layer.cornerRadius = min(button.frame.width, button.frame.height) * 0.3
        button.layer.masksToBounds = true
        button.widthAnchor.constraint(equalToConstant: button.frame.size.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.frame.size.height).isActive = true
        button.addTarget(self, action: #selector(type(of: self).dismissAction), for: .touchUpInside)
        return button
    }()
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.tintColor = .white
        button.backgroundColor = UIColor.themeColor()
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.setImage(R.image.icon_share()?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.layer.cornerRadius = min(button.frame.width, button.frame.height) * 0.2
        button.layer.masksToBounds = true
        button.widthAnchor.constraint(equalToConstant: button.frame.size.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.frame.size.height).isActive = true
        button.addTarget(self, action: #selector(type(of: self).showShareModal), for: .touchUpInside)
        return button
    }()
    lazy var seekBar: UISlider = {
        let seekBar = UISlider()
        seekBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 80, height: 50)
        seekBar.minimumValue = 0
        seekBar.thumbTintColor = .lightGray
        return seekBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: dismissButton)]
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: shareButton)]
        view.backgroundColor = .black
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(type(of: self).doPlay)))
        view.addSubview(seekBar)

        configureVideoPlayer()
    }
}

// MARK: selectors

extension PlayerViewController {
    @objc func dismissAction() {
        player?.pause()
        player = nil
        playerLayer = nil
        dismiss(animated: true, completion: nil)
    }
    @objc func showShareModal() {
        let activity = UIActivityViewController(activityItems: [viewModel.url], applicationActivities: nil)
        activity.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .airDrop]
        activity.completionWithItemsHandler = { (_, _, _, _) in
            self.dismiss(animated: true, completion: nil)
        }
        present(activity, animated: true, completion: nil)
    }
    @objc func doPlay() {
        player?.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC)))
        player?.play()
    }
}

// MARK: private functions

extension PlayerViewController {
    private func configureVideoPlayer() {
        let asset = AVURLAsset(url: viewModel.url)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        player.actionAtItemEnd = .none

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.backgroundColor = UIColor.clear.cgColor

        view.layer.addSublayer(playerLayer)

        let interval = CMTimeMakeWithSeconds(Double(0.5 * seekBar.maximumValue) / Double(seekBar.bounds.maxX), preferredTimescale: Int32(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { _ in
            let duration = CMTimeGetSeconds(player.currentItem!.duration)
            let currentTime = CMTimeGetSeconds(player.currentTime())
            self.seekBar.value = Float(self.seekBar.maximumValue - self.seekBar.minimumValue) * Float(currentTime) / Float(duration) + Float(self.seekBar.minimumValue)
        }

        playerLayer.frame = CGRect(x: 40, y: 40, width: view.bounds.width - 80, height: view.bounds.height - 80)
        seekBar.layer.position = CGPoint(x: view.bounds.midX, y: view.bounds.height - 70)

        self.player = player
        self.playerLayer = playerLayer

        player.play()
    }
}
