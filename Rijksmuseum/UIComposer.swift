//
//  UIComposer.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import Foundation
import RijksmuseumFeed
import UIKit

final class UIComposer {
    static func makeFeedViewController() -> FeedViewController {
        let apiLoader = UIComposer.makeRemoteFeedLoader()
        let feedViewController = FeedViewController(loader: apiLoader, imageLoader: DummyImageDataLoader())
        return feedViewController
    }
    
    private static func makeRemoteFeedLoader() -> FeedLoader {
        let httpClient = RMAuthorizedHttpClient(client: URLSessionHTTPClient())
        let loader = RemoteFeedLoader(client: httpClient)
        return loader
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
