import UIKit

final class FilterRepository {
    let elements: [Element]

    struct Element {
        let type: FilterType
        let filter: CIFilter
    }

    init() {
        let items: [FilterType] = FilterType.allCases
        let elements = items
            .map { type -> Element? in
                guard let filter = CIFilter(name: type.rawValue) else {
                    return nil
                }
                return Element(type: type, filter: filter)
            }
            .filter { $0 != nil }
            .map { $0! }
        self.elements = elements
    }
}
