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
    var onFeedLoadError: Observer<Error>?

    func loadFeed(page: Int = 1) {
        onLoadingStateChange?(true)
        feedLoader.load(page: page) { [weak self] result in
            self?.onLoadingStateChange?(false)
            switch result {
            case let .success(feed):
                if page == 1 {
                    self?.onFeedReset?()
                }
                self?.onFeedLoad?(feed)
            case let .failure(error):
                self?.onFeedLoadError?(error)
            }
        }
    }
}
