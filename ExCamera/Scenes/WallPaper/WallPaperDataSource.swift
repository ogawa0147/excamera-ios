import UIKit

final class WallPaperDataSource: NSObject, UICollectionViewDataSource {
    typealias Element = [GifImageSource]
    var items: Element = []

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WallPaperGifCell", for: indexPath) as? WallPaperGifCell else {
            fatalError()
        }
        cell.bind(items[indexPath.row])
        return cell
    }
}
