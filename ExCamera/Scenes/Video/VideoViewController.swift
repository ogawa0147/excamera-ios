import UIKit
import Photos
import ImageIO
import MobileCoreServices
import DIKit
import Utility

final class VideoViewController: UITableViewController, FactoryMethodInjectable {
    struct Dependency {
        let resolver: AppResolver
        let viewModel: VideoViewModel
    }

    static func makeInstance(dependency: Dependency) -> VideoViewController {
        let viewController = StoryboardScene.VideoViewController.videoViewController.instantiate()
        viewController.dependency = dependency
        return viewController
    }

    private var dependency: Dependency!

    private var videoAssets: [PHAsset] = []
    private var selectedVideoAsset: PHAsset?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(VideoViewController.convertVideoToGif)
        )

        // アクセス認証
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { _ in
                self.loadVideos {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }

        loadVideos {
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoAssets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else {
            NSLog("%d: %@", #line, "TableViewCell = nil")
            fatalError()
        }
        PHImageManager.default().requestPlayerItem(forVideo: videoAssets[indexPath.row], options: nil) { playerItem, _ in
            guard let asset = playerItem?.asset else {
                NSLog("%d: %@", #line, "playerItem.asset = nil")
                return
            }
            do {
                // 動画の指定した時間での画像を得る（動画の最後は「asset.duration」を指定する）
                let startFrame: CMTime = CMTimeMake(value: 0, timescale: 600)
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                let imageRef: CGImage! = try generator.copyCGImage(at: startFrame, actualTime: nil)

                DispatchQueue.main.async {
                    // 切り出した画像をイメージビューで表示
                    cell.videoImageView.image = UIImage(cgImage: imageRef)

                    // 動画の尺をラベルに表示
                    cell.videoLengthLabel.text = String(format: "%02d:%02d", Int(asset.duration.seconds) / 60, Int(asset.duration.seconds) % 60)
                }

            } catch let error as NSError {
                NSLog("%d: %@", #line, error)
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVideoAsset = videoAssets[indexPath.row]
    }

    // ビデオの一覧を取得する
    private func loadVideos(_ closure: @escaping () -> Void) {
        // メディアタイプをビデオに指定
        let assets = PHAsset.fetchAssets(with: .video, options: nil)
        assets.enumerateObjects { asset, index, _ in
            self.videoAssets.append(asset)
            if index == assets.count-1 {
                closure()
            }
        }
    }

    /*
     * ビデオからGIFに変換する
     *
     * AVPlayerItem
     * - AVPlayerItem.duration: メディアファイルの長さ
     * - AVPlayerItem.presentationSize: 映像データの標準の表示サイズ
     * - AVPlayerItem.status: AVPlayerItem が再生できるかできないかの状態
     * - AVPlayerItem.currentTime(): 現在の再生位置の時間
     * - AVPlayerItem.seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: ((Bool) -> Swift.Void)? = nil): 時間を指定してその位置に再生位置を移動する
     * - AVPlayerItem.step(byCount stepCount: Int): 前後のフレームに移動
     *
     * AVAsset <= これをメインに使う
     * - AVAsset.duration: メディアファイルの長さ
     * - AVAsset.metadata: メタデータ、AVMetadataItem 配列
     *
     */
    @objc
    func convertVideoToGif() {
        guard let videoAsset = selectedVideoAsset else {
            NSLog("%d: %@", #line, "selectedVideoAsset = nil")
            return
        }
        PHImageManager.default().requestPlayerItem(forVideo: videoAsset, options: nil) { playerItem, _ in
            do {
                guard let asset = playerItem?.asset else {
                    NSLog("%d: %@", #line, "playerItem.asset = nil")
                    return
                }

                // サムネイル作成
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true

                // 指定した時間のCGImageを作成
                var capturedImages: [CGImage] = [CGImage]()

                // GIFを作る画像の枚数の上限 滑らかな動きをするGIFを作るにはフレームレートを調整する必要がありそう
                let frameCount: Int = 25
                for second in 0..<frameCount {
                    // 動画の開始 冒頭から3秒を表す例 => CMTime start = CMTimeMake(0, 600); CMTime duration = CMTimeMake(1800, 600); CMTimeRange range = CMTimeRangeMake(start, duration);
                    let rate = CMTimeMake(value: 100, timescale: 200)
                    let startFrame = CMTime(seconds: rate.seconds * Double(second), preferredTimescale: 60)
                    let imageRef: CGImage! = try generator.copyCGImage(at: startFrame, actualTime: nil)
                    capturedImages.append(imageRef)
                    NSLog("%d: %f", #line, CMTimeGetSeconds(startFrame))
                }

                // ループカウント（アニメーションの再生回数, 0で無限ループ）
                let fileProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]]

                // フレームレート（アニメーションの切り替わる速さ）
                // value/timescale = seconds => 100/500 = 1フレームあたり0.2秒
                // kCGImagePropertyGIFDelayTimeの値はフレームレート（秒数）
                let frameRate = CMTimeMake(value: 100, timescale: 500)
                let frameProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: CMTimeGetSeconds(frameRate)]]

                // GIF画像の保存先（hoge.gifという名前で一時的に保存）
                let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("hoge.gif")

                // CGImageDestinationの作成
                guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeGIF, capturedImages.count, nil) else {
                    NSLog("%d: %@", #line, "destination = nil")
                    return
                }

                // 保存するGIF画像データのプロパティを設定
                CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)

                capturedImages.forEach { image in
                    CGImageDestinationAddImage(destination, image, frameProperties as CFDictionary)
                }

                // GIF画像を生成する
                CGImageDestinationFinalize(destination)

                DispatchQueue.main.async {
                    let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    self.present(controller, animated: true, completion: nil)
                }

            } catch let error as NSError {
                NSLog("%d: %@", #line, error)
            }
        }

        selectedVideoAsset = nil
    }

    /*
     * 元の動画の長さが10秒だとして、その動画の2～5秒の部分を切り出す場合の例
     */
    // swiftlint:disable function_body_length
    private func cutVideoEx(asset: AVAsset) {

        let videoFPS: Int32 = 30

        let startTime: Double = 2
        let duration: Double = 3

        // 出力場所
        guard let outputPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.localDomainMask, true).first else {
            return
        }

        // 動画処理の設定
        let composition = AVMutableComposition()
        guard let compositionVideoTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return
        }

        // 切り出す範囲を設定
        if startTime >= CMTimeGetSeconds(asset.duration) || startTime < 0 || duration <= 0 {
            return
        }
        let rangeStart: CMTime = CMTimeMakeWithSeconds(startTime, preferredTimescale: videoFPS)
        let rangeDuration: CMTime = CMTimeMakeWithSeconds(duration, preferredTimescale: videoFPS)
        let inputRange: CMTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
        let outputRange: CMTimeRange = CMTimeRangeMake(start: rangeStart, duration: rangeDuration)

        // assetからビデオトラックを抜き出す
        guard let videoTrack: AVAssetTrack = asset.tracks(withMediaType: AVMediaType.video).first else {
            return
        }

        // 出力するビデオのトラックを設定
        try? compositionVideoTrack.insertTimeRange(outputRange, of: videoTrack, at: CMTime.zero)

        // AVMutableVideoCompositionInstructionインスタンスを作成、元動画への様々な処理を設定するために必要
        let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = inputRange

        // 出力する動画の縦横サイズを決定
        let layerInstruction: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)

        var videoSize: CGSize = videoTrack.naturalSize
        let transform: CGAffineTransform = videoTrack.preferredTransform
        if transform.a == 0 && transform.d == 0 && (transform.b == 1.0 || transform.b == -1.0) && (transform.c == 1.0 || transform.c == -1.0) {
            videoSize = CGSize(width: videoSize.height, height: videoSize.width)
        }

        // 変換行列をlayerInstructionに設定（移動や回転等の処理）
        layerInstruction.setTransform(transform, at: CMTime.zero)
        instruction.layerInstructions = [layerInstruction]

        // 最終的に出力するビデオの設定
        let videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.instructions = [instruction]
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: videoFPS)

        // 出力するファイルと同名のファイルがある場合に削除
        let fileManager: FileManager = FileManager.default
        if fileManager.fileExists(atPath: outputPath) {
            try? fileManager.removeItem(atPath: outputPath)
        }

        // 出力するためのセッションであるAVAssetExportSessionインスタンスを作成
        guard let session: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            return
        }
        session.outputURL = URL(fileURLWithPath: outputPath)
        session.outputFileType = AVFileType.mov
        session.videoComposition = videoComposition

        // 最終出力
        session.exportAsynchronously {
            if session.status == AVAssetExportSession.Status.completed {
                print("output complete!")
            } else {
                print("output error!: \(String(describing: session.error))")
            }
        }
    }
}

class TableViewCell: UITableViewCell {
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoLengthLabel: UILabel!
}
