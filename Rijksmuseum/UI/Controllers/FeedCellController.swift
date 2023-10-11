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
    private(set) var model: FeedItem
    private let imageLoader: ImageLoader
    private var task: ImageLoaderTask?
    
    init(collectionView: UICollectionView, model: FeedItem, imageLoader: ImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
        self.collectionView = collectionView
    }

    func view(for indexPath: IndexPath) -> UICollectionViewCell {
        let id = String(describing: FeedItemCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! FeedItemCell
        cell.configure(with: model)
        cell.imageContainer.startShimmering()
        
        self.task = imageLoader.loadImage(from: model.imageUrl) { [weak cell] result in
            if let image = try? result.get() {
                cell?.fadeIn(image)
            }
        }
        return cell
    }
    
    func preload() {
        self.task = self.imageLoader.loadImage(from: self.model.imageUrl) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}

extension FeedCellController: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(model.id)
    }
    
    static func == (lhs: FeedCellController, rhs: FeedCellController) -> Bool {
        lhs.model.id == rhs.model.id
    }
}
