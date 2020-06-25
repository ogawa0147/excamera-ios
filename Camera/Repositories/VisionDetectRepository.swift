import Foundation

final class VisionDetectRepository {
    let elements: [Element]

    struct Element {
        let object: VisionDetector
        let type: VisionDetectType
    }

    init() {
        let items: [VisionDetectType] = VisionDetectType.allCases
        let elements = items.map { type -> Element in
            return Element(object: VisionDetectFace(), type: type)
        }
        self.elements = elements
    }
}
