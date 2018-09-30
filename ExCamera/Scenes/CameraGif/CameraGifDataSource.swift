import UIKit

final class CameraGifDataSource: NSObject, UICollectionViewDataSource {
    typealias Element = [GifImageSource]
    var items: Element = []

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraGifCell", for: indexPath) as? CameraGifCell else {
            fatalError()
        }
        cell.bind(items[indexPath.row])
        return cell
    }
}
