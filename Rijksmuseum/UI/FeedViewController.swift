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

class FeedViewController: UICollectionViewController {
    var feed = [FeedItemViewModel]()
    let refreshControl = UIRefreshControl()
    
    var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init(collectionViewLayout: UICollectionViewLayout())
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        collectionView.collectionViewLayout = compositionalLayout
        collectionView.refreshControl = refreshControl
        
        loader?.load(completion: { _ in
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        collectionView.setContentOffset(CGPoint(x: 0.0, y: -refreshControl.frame.size.height), animated: true)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        feed.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feedCell", for: indexPath) as! FeedItemCell
        let model = feed[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    @IBAction func refresh() {
        refreshControl.beginRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.feed.isEmpty {
                self.feed = FeedItemViewModel.prototypeFeed
                self.collectionView.reloadData()
            }
            self.refreshControl.endRefreshing()
        }
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

