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
        imageLoader: ImageLoader) -> FeedViewController
    {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(refreshController: refreshController)
        let dataSource = FeedDataSource(collectionView: feedViewController.collectionView) { [weak feedViewController] collectionView, indexPath, itemIdentifier in
            feedViewController?.cellController(forRowAt: indexPath)?.view(for: indexPath)
        }
        refreshController.resetDataSource = { [weak dataSource] in
            dataSource?.reset()
        }

        feedViewController.dataSource = dataSource
        refreshController.onFeedRefresh = adaptFeedModelToCellControllers(
            dataSource: dataSource,
            collectionView: feedViewController.collectionView,
            imageLoader: imageLoader)

        return feedViewController
    }
    
    private static func adaptFeedModelToCellControllers(dataSource: FeedDataSource, collectionView: UICollectionView, imageLoader: ImageLoader) -> ([FeedItem]) -> Void {
        { [weak dataSource] feed in
            guard let dataSource else { return }
            let controllers = feed.map {
                FeedCellController(collectionView: collectionView,
                                   model: $0, imageLoader: imageLoader)
            }
            dataSource.append(controllers)
        }
    }
    
    private struct CacheSettings {
        static let memoryImageCacheSize = 1024 * 1024 * 10
        static let diskImageCacheSize = 1024 * 1024 * 300
    }
    
    static func makeFeedViewController() -> FeedViewController {
        let httpClient = RMAuthorizedHttpClient(URLSessionHTTPClient())
        let feedLoader = RemoteFeedLoaderMainThreadDispatcher(RemoteFeedLoader(client: httpClient))
        
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(memoryCapacity: CacheSettings.memoryImageCacheSize, diskCapacity: CacheSettings.diskImageCacheSize)
        let urlSession = URLSession(configuration: configuration)
        let remoteImageDataLoader = RemoteImageDataLoader(session: urlSession)
        let imageCache = MemoryImageCache(resizeBlock: ImageResizer.decodeAndResize)
        let cacheImageLoader = CacheImageLoader(cache: imageCache, fallbackLoader: remoteImageDataLoader)
        let imageLoader = ImageLoaderMainThreadDispatcher(imageLoader: cacheImageLoader)
        
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
