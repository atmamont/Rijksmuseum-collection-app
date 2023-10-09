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

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    private let refreshController: FeedRefreshViewController
    
    var dataSource: FeedDataSource?
    var currentPage = 1
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(refreshController: FeedRefreshViewController) {
        self.refreshController = refreshController
        super.init(nibName: nil, bundle: nil)
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
        collectionView.dataSource = dataSource
        
        collectionView.refreshControl = refreshController.refreshControl
        
        view.addFillingSubview(collectionView)

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
    
    private func loadMore() {
        currentPage += 1
        refreshController.load(page: currentPage)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cellController = cellController(forRowAt: indexPath), let dataSource else { return }
        print("Checking for load more for item at \(indexPath)")
        if dataSource.isLastItemInLastSection(cellController) {
            print("Loading more at \(indexPath)")
            loadMore()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelImageLoad(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath)?.preload()
        }
    }
    
    func cellController(forRowAt indexPath: IndexPath) -> FeedCellController? {
        dataSource?.itemIdentifier(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelImageLoad)
    }
    
    private func cancelImageLoad(at indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.cancelLoad()
    }
}
