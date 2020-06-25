import Foundation
import AVFoundation

/*
 * AVAudioPlayer
 * https://developer.apple.com/documentation/avfoundation/avaudioplayer
 *
 */

class AudioPlayer {
    let player: AVAudioPlayer

    init(audioURL: URL) {
        guard let player = try? AVAudioPlayer(contentsOf: audioURL) else {
            fatalError()
        }
        self.player = player
        self.player.prepareToPlay()
    }
}
