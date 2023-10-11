//
//  FeedViewModel.swift
//  Rijksmuseum
//
//  Created by Andrei on 11/10/2023.
//

import Foundation
import RijksmuseumFeed

typealias Observer<T> = (T) -> Void

final class FeedViewModel {
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedReset: (() -> Void)?
    var onFeedLoad: Observer<[FeedItem]>?

    func loadFeed(page: Int = 1) {
        onLoadingStateChange?(true)
        feedLoader.load(page: page) { [weak self] result in
            if let feed = try? result.get() {
                if page == 1 {
                    self?.onFeedReset?()
                }
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
