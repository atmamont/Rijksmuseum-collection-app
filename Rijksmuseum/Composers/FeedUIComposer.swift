//
//  UIComposer.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import Foundation
import RijksmuseumFeed
import UIKit

final class FeedUIComposer {
    private init() {}
    
    public static func composeFeedViewController(
        feedLoader: FeedLoader,
        imageLoader: ImageDataLoader) -> FeedViewController
    {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(refreshController: refreshController)
        
        refreshController.onFeedRefresh = adaptFeedModelToCellControllers(
            destinationController: feedViewController,
            imageLoader: imageLoader)

        return feedViewController
    }
    
    private static func adaptFeedModelToCellControllers(destinationController feedViewController: FeedViewController, imageLoader: ImageDataLoader) -> ([FeedItem]) -> Void {
        return { [weak feedViewController] feed in
            guard let feedViewController else { return }
            feedViewController.feed = feed.map {
                FeedCellController(
                    collectionView: feedViewController.collectionView,
                    model: $0,
                    imageLoader: imageLoader)
            }
        }
    }
    
    private struct CacheSettings {
        static let memoryImageCacheSize = 1024 * 1024 * 1
        static let diskImageCacheSize = 1024 * 1024 * 300
    }
    
    static func makeFeedViewController() -> FeedViewController {
        let httpClient = RMAuthorizedHttpClient(URLSessionHTTPClient())
        let feedLoader = RemoteFeedLoaderMainThreadDispatcher(RemoteFeedLoader(client: httpClient))
        
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(memoryCapacity: CacheSettings.memoryImageCacheSize, diskCapacity: CacheSettings.diskImageCacheSize)
        let urlSession = URLSession(configuration: configuration)
        let imageLoader = RemoteImageDataLoaderMainThreadDispatcher(imageLoader: RemoteImageDataLoader(session: urlSession))
        
        let feedViewController = composeFeedViewController(feedLoader: feedLoader, imageLoader: imageLoader)
        return feedViewController
    }
}

private class DummyImageDataLoader: ImageDataLoader {
    class DummyImageDataLoaderTask: ImageDataLoaderTask {
        func cancel() {
            // dummy
        }
    }
    func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
        completion(.success(Data()))
        return DummyImageDataLoaderTask()
    }
}
