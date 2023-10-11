//
//  FeedViewModel.swift
//  Rijksmuseum
//
//  Created by Andrei on 11/10/2023.
//

import Foundation
import RijksmuseumFeed

final class FeedViewModel {
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    
    var onFeedReset: (() -> Void)?
    var onFeedLoad: (([FeedItem]) -> Void)?

    
    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }
    
    func loadFeed(page: Int = 1) {
        isLoading = true
        feedLoader.load(page: page) { [weak self] result in
            if let feed = try? result.get() {
                if page == 1 {
                    self?.onFeedReset?()
                }
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}
