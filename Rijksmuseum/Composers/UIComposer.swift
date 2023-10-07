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
        let httpClient = RMAuthorizedHttpClient(URLSessionHTTPClient())
        let loader = RemoteFeedLoaderMainThreadDispatcher(RemoteFeedLoader(client: httpClient))
        let feedViewController = FeedViewController(feedLoader: loader, imageLoader: DummyImageDataLoader())
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
