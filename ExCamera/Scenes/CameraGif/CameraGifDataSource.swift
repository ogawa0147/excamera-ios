import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class CameraGifDataSource: NSObject, UICollectionViewDataSource, RxCollectionViewDataSourceType {
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

    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
        guard case .next(let newItems) = observedEvent else { return }
        items = newItems
        collectionView.reloadData()
    }
}
