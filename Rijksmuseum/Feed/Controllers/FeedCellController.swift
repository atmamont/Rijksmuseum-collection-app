//
//  FeedCellController.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import UIKit

final class FeedCellController {
    private let collectionView: UICollectionView
    private(set) var viewModel: FeedItemViewModel
    
    init(collectionView: UICollectionView, viewModel: FeedItemViewModel) {
        self.viewModel = viewModel
        self.collectionView = collectionView
    }

    func view(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = binded(collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: FeedItemCell.self),
            for: indexPath
        ) as! FeedItemCell)
        preload()
        return cell
    }
    
    func preload() {
        viewModel.loadImage()
    }
    
    func cancelLoad() {
        viewModel.cancelImageLoad()
    }
    
    private func binded(_ cell: FeedItemCell) -> FeedItemCell {
        cell.titleLabel.text = viewModel.title
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.fadeIn(image)
        }
        
        viewModel.onImageLoadStateChange = { [weak cell] isLoading in
            if isLoading {
                cell?.imageContainer.startShimmering()
            } else {
                cell?.imageContainer.stopShimmering()
            }
        }
        
        return cell
    }
}

extension FeedCellController: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(viewModel.id)
    }
    
    static func == (lhs: FeedCellController, rhs: FeedCellController) -> Bool {
        lhs.viewModel.id == rhs.viewModel.id
    }
}
