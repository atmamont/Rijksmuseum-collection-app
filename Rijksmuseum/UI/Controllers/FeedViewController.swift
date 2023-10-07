//
//  FeedViewController.swift
//  Rijksmuseum
//
//  Created by Andrei on 03/10/2023.
//

import UIKit
import RijksmuseumFeed


struct FeedItemViewModel {
    let title: String
    let imageName: String
}

class FeedViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching {
    var feed = [FeedItem]() {
        didSet {
            collectionView.reloadData()
        }
    }
    var cellControllers = [IndexPath: FeedCellController]()
    
    var refreshController: FeedRefreshViewController
    var imageLoader: ImageDataLoader
    
    init(feedLoader: FeedLoader,
         imageLoader: ImageDataLoader) {
        self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
        
        super.init(collectionViewLayout: compositionalLayout)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = compositionalLayout
        collectionView.register(FeedItemCell.self, forCellWithReuseIdentifier: "FeedItemCell")
        collectionView.prefetchDataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.refreshControl = refreshController.refreshControl
        refreshController.onFeedRefresh = { [weak self] feed in
            self?.feed = feed
        }
        
        refreshController.load()
    }
        
    //MARK: - Layout
    
    private let compositionalLayout: UICollectionViewCompositionalLayout = {
        let fraction: CGFloat = 1 / 2
        let inset = 5.0
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(fraction))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }()
}

extension FeedViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        feed.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellController = cellController(forRowAt: indexPath)
        cellControllers[indexPath] = cellController
        return cellController.view(for: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelImageLoad(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellControllers[indexPath] = cellController(forRowAt: indexPath)
            cellControllers[indexPath]?.preload()
        }
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedCellController {
        FeedCellController(
            collectionView: collectionView,
            model: feed[indexPath.item],
            imageLoader: imageLoader)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelImageLoad)
    }
    
    private func cancelImageLoad(at indexPath: IndexPath) {
        cellControllers[indexPath]?.cancelLoad()
    }
}
