//
//  FeedViewController.swift
//  Rijksmuseum
//
//  Created by Andrei on 03/10/2023.
//

import UIKit

public final class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    private let refreshController: FeedRefreshViewController
    
    var dataSource: FeedDataSource?
    var onFeedItemTap: ((_ objectNumber: String) -> Void)?
    
    private var currentPage = 1

    init(refreshController: FeedRefreshViewController) {
        self.refreshController = refreshController
        super.init(nibName: nil, bundle: nil)
        
        title = NSLocalizedString("feed_screen_title", comment: "Feed screen - Title")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = compositionalLayout
        collectionView.register(FeedItemCell.self, forCellWithReuseIdentifier: "FeedItemCell")
        collectionView.register(FeedSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FeedSectionHeader")
        collectionView.prefetchDataSource = self
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        
        collectionView.refreshControl = refreshController.refreshControl
        
        view.addFillingSubview(collectionView)

        refreshController.load()
    }
    
    private func loadMore() {
        currentPage += 1
        refreshController.load(page: currentPage)
    }
    
    private func isVeryLastItem(at indexPath: IndexPath) -> Bool {
        (indexPath.section == collectionView.numberOfSections - 1) && (indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isVeryLastItem(at: indexPath) {
            loadMore()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelImageLoad(at: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath)?.preload()
        }
    }
    
    func cellController(forRowAt indexPath: IndexPath) -> FeedCellController? {
        dataSource?.itemIdentifier(for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelImageLoad)
    }
    
    private func cancelImageLoad(at indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.cancelLoad()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        onFeedItemTap?(item.viewModel.id)
    }
    
    func sectionHeader(for indexPath: IndexPath) -> UICollectionReusableView {
        let section = dataSource?.sectionIdentifier(for: indexPath.section)
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "FeedSectionHeader",
            for: indexPath
        ) as! FeedSectionHeader
        header.titleLabel.text = section?.maker
        return header
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
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(50.0))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: headerSize,
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top)
        section.boundarySupplementaryItems = [header]
        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
