import UIKit

final class ARCameraDataSource: NSObject, UICollectionViewDataSource {
    typealias Element = [ARCameraViewModel.Section]
    var items: Element = []

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items[section].elements.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch items[indexPath.section].elements[indexPath.row] {
        case .gif(let element):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ARCameraGifCell", for: indexPath) as? ARCameraGifCell else {
                fatalError()
            }
            cell.bind(element)
            return cell
        }
    }
}
