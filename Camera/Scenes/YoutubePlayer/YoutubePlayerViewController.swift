import UIKit
import Photos
import ImageIO
import MobileCoreServices
import DIKit

final class YoutubePlayerViewController: UIViewController, YouTubePlayerDelegate, FactoryMethodInjectable {
    struct Dependency {
        let resolver: AppResolver
        let viewModel: YoutubePlayerViewModel
    }

    static func makeInstance(dependency: Dependency) -> YoutubePlayerViewController {
        let viewController = StoryboardScene.YoutubePlayerViewController.youtubePlayerViewController.instantiate()
        viewController.dependency = dependency
        return viewController
    }

    private var dependency: Dependency!

    var videoPlayer: YouTubePlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        videoPlayer = YouTubePlayerView(frame: view.frame)
        videoPlayer.playerVars = [
            "playsinline": "1" as AnyObject,
            "controls": "0" as AnyObject,
            "showinfo": "0" as AnyObject,
            "autoplay": "1" as AnyObject
        ]
        videoPlayer.loadVideoID("Z93vwdSQoaU")
        videoPlayer.delegate = self
        videoPlayer.play()

        view.addSubview(videoPlayer)
    }

    func playerReady(_ videoPlayer: YouTubePlayerView) {}

    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {}

    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {}
}
