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
    
    public static func composeFeedViewController(navigationController: UINavigationController) -> FeedViewController {
        let httpClient = AuthorizedHttpClient(
            URLSessionHTTPClient(),
            authorizationKey: Settings.apiKey)
        let feedLoader = FeedLoaderMainThreadDispatcher(RemoteFeedLoader(client: httpClient))
        let imageLoader = cachedImageLoader()
        let feedViewController = composeFeedViewController(feedLoader: feedLoader, imageLoader: imageLoader, navigationController: navigationController)
        return feedViewController
    }

    public static func composeFeedViewController(
        feedLoader: FeedLoader,
        imageLoader: ImageLoader,
        navigationController: UINavigationController? = nil) -> FeedViewController
    {
        let feedViewController = composeFeedViewController(feedLoader: feedLoader, imageLoader: imageLoader)
        feedViewController.onFeedItemTap = { objectNumber in
            let feedItemDetailsViewController = composeFeedItemDetailsViewController(objectNumber: objectNumber)
            navigationController?.pushViewController(feedItemDetailsViewController, animated: true)
        }
        return feedViewController
    }

    private static func composeFeedViewController(
        feedLoader: FeedLoader,
        imageLoader: ImageLoader) -> FeedViewController
    {
        let viewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: viewModel)
        let feedViewController = FeedViewController(refreshController: refreshController)
        let dataSource = FeedDataSource(
            collectionView: feedViewController.collectionView
        ) { [weak feedViewController] collectionView, indexPath, itemIdentifier in
            feedViewController?.cellController(forRowAt: indexPath)?.view(for: indexPath)
        }
        viewModel.onFeedReset = { [weak dataSource] in
            dataSource?.reset()
        }

        feedViewController.dataSource = dataSource
        viewModel.onFeedLoad = adaptFeedModelToCellControllers(
            dataSource: dataSource,
            collectionView: feedViewController.collectionView,
            imageLoader: imageLoader)

        return feedViewController
    }
    
    private static func adaptFeedModelToCellControllers(
        dataSource: FeedDataSource,
        collectionView: UICollectionView,
        imageLoader: ImageLoader
    ) -> ([FeedItem]) -> Void {
        { [weak dataSource] feed in
            guard let dataSource else { return }
            let controllers = feed.map {
                FeedCellController(collectionView: collectionView,
                                   viewModel: FeedItemViewModel(model: $0, imageLoader: imageLoader))
            }
            dataSource.append(controllers)
        }
    }
    
    private static func composeFeedItemDetailsViewController(objectNumber: String) -> FeedItemDetailsViewController {
        let httpClient = AuthorizedHttpClient(
            URLSessionHTTPClient(),
            authorizationKey: Settings.apiKey)
        let loader = FeedItemLoaderMainThreadDispatcher(RemoteFeedItemLoader(client: httpClient))
        let imageLoader = cachedImageLoader()
        let viewModel = FeedItemDetailsViewModel(objectNumber: objectNumber, loader: loader, imageLoader: imageLoader)
        let viewController = FeedItemDetailsViewController(viewModel: viewModel)
        return viewController
    }

    private struct Settings {
        struct Cache {
            static let memoryImageCacheSize = 1024 * 1024 * 10
            static let diskImageCacheSize = 1024 * 1024 * 300
        }
        
        static let apiKey = "0fiuZFh4"
    }
    
    private static func cachedURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(
            memoryCapacity: Settings.Cache.memoryImageCacheSize,
            diskCapacity: Settings.Cache.diskImageCacheSize
        )
        
        return URLSession(configuration: configuration)
    }
    
    private static func cachedImageLoader() -> ImageLoader {
        let remoteImageDataLoader = RemoteImageDataLoader(session: cachedURLSession())
        let imageCache = MemoryImageCache(resizeBlock: { image, _ in image})
        let cacheImageLoader = CacheImageLoader(
            cache: imageCache,
            fallbackLoader: remoteImageDataLoader
        )
        return ImageLoaderMainThreadDispatcher(imageLoader: cacheImageLoader)
    }
}
