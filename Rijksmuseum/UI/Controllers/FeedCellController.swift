//
//  FeedCellController.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import UIKit
import RijksmuseumFeed

final class FeedCellController {
    private let collectionView: UICollectionView
    private let model: FeedItem
    private let imageLoader: ImageDataLoader
    private var task: ImageDataLoaderTask?
    
    init(collectionView: UICollectionView, model: FeedItem, imageLoader: ImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
        self.collectionView = collectionView
    }

    func view(for indexPath: IndexPath) -> UICollectionViewCell {
        let id = String(describing: FeedItemCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! FeedItemCell
        cell.configure(with: model)
        self.task = imageLoader.loadImageData(from: model.imageUrl) { [weak cell] result in
            if let data = try? result.get() {
                cell?.fadeIn(UIImage.init(data: data))
            }
            cell?.imageContainer.stopShimmering()
        }
        return cell
    }
    
    func preload() {
        task = imageLoader.loadImageData(from: model.imageUrl) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
