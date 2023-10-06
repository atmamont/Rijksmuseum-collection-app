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

protocol ImageDataLoaderTask {
    func cancel()
}

protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageDataLoaderTask
}

class FeedViewController: UICollectionViewController {
    var feed = [FeedItem]()
    let refreshControl = UIRefreshControl()
    var tasks = [IndexPath: ImageDataLoaderTask]()
    
    var feedLoader: FeedLoader?
    var imageLoader: ImageDataLoader?
    
    convenience init(loader: FeedLoader, imageLoader: ImageDataLoader) {
        self.init(collectionViewLayout: UICollectionViewLayout())
        self.feedLoader = loader
        self.imageLoader = imageLoader
    }
    
    @objc private func load() {
        refreshControl.beginRefreshing()

        feedLoader?.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.feed = (try? result.get()) ?? []
                self?.collectionView.reloadData()
            case .failure:
                break
            }
            self?.refreshControl.endRefreshing()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if feed.isEmpty {
            refreshControl.beginRefreshing()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = compositionalLayout
        collectionView.refreshControl = refreshControl
        collectionView.register(FeedItemCell.self, forCellWithReuseIdentifier: "FeedItemCell")
        
        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedItemCell", for: indexPath) as! FeedItemCell
        let model = feed[indexPath.row]
        cell.configure(with: model)
        cell.imageContainer.startShimmering()
        cell.imageView.image = nil
        tasks[indexPath] = imageLoader?.loadImageData(from: model.imageUrl) { [weak cell] result in
            if let data = try? result.get() {
                cell?.imageView.image = UIImage.init(data: data, scale: 1.0)
            }
            cell?.imageContainer.stopShimmering()
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
