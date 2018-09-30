import UIKit

final class CameraEffectDataSource: NSObject, UICollectionViewDataSource {
    typealias Element = [EffectViewSource]
    var items: Element = []

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraEffectCell", for: indexPath) as? CameraEffectCell else {
            fatalError()
        }
        cell.bind(items[indexPath.row])
        return cell
    }
}
