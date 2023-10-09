//
//  FeedRefreshViewController.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import UIKit
import RijksmuseumFeed

final class FeedRefreshViewController: UIViewController {
    private(set) lazy var refreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(pullToResfresh), for: .valueChanged)
        return control
    }()
    
    private let feedLoader: FeedLoader
    
    var onFeedRefresh: (([FeedItem]) -> Void)?
    var resetDataSource: (() -> Void)?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = refreshControl
    }
    
    func load(page: Int = 1) {
        refreshControl.beginRefreshing()

        feedLoader.load(page: page) { [weak self] result in
            switch result {
            case let .success(feed):
                self?.onFeedRefresh?(feed)
            case let .failure(error):
                print(error)
            }
            self?.refreshControl.endRefreshing()
        }
    }
    
    @objc private func pullToResfresh() {
        resetDataSource?()
        load(page: 1)
    }
}
