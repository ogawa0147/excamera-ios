import Foundation
import Photos

final class AudioRepository {
    let elements: [Element]

    struct Element {
        let data: Data
        let fileURL: URL
    }

    enum FileType: String {
        case m4a
        case mp3
    }

    init() {
        let items: [DataAsset] = [Asset.Assets.track01]
        let elements = items.map { dataAsset -> Element in
            let outputFileType = (dataAsset.data.data as NSData).toFileType()
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let fileURL = URL(fileURLWithPath: path).appendingPathComponent("\(dataAsset.name).\(outputFileType)")
            var data: Data
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    // データに変更があれば書き直す
                    let audioData = try Data(contentsOf: fileURL)
                    if dataAsset.data.data != audioData {
                        try FileManager.default.removeItem(atPath: fileURL.path)
                        // NSDataAssetからURLを取得できないので指定の場所に保存してから使う
                        try dataAsset.data.data.write(to: fileURL, options: [.atomic])
                    }
                    data = audioData
                } catch let error {
                    fatalError("\(error.localizedDescription)")
                }
            } else {
                do {
                    // NSDataAssetからURLを取得できないので指定の場所に保存してから使う
                    try dataAsset.data.data.write(to: fileURL, options: [.atomic])
                    data = dataAsset.data.data
                } catch let error {
                    fatalError("\(error.localizedDescription)")
                }
            }
            return Element(data: data, fileURL: fileURL)
        }
        self.elements = elements
    }
}

private extension AVFileType {
    func toFileType() -> AudioRepository.FileType {
        switch self {
        case .m4a: return .m4a
        case .mp3: return .mp3
        default:
            fatalError()
        }
    }
}

private extension NSData {
    func toFileType() -> AudioRepository.FileType {
        var values = [UInt32](repeating: 0, count: 1)
        getBytes(&values, length: 1)
        switch values[0] {
        case 73: return .mp3
        default: return .m4a
        }
    }
}
