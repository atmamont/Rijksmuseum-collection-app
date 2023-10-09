//
//  FeedLoaderMainThreadDispatcher.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import Foundation

public final class FeedLoaderMainThreadDispatcher: FeedLoader {
    let loader: FeedLoader
    
    public init(_ loader: FeedLoader) {
        self.loader = loader
    }
    
    public func load(page: Int = 0, completion: @escaping ((FeedLoader.Result) -> Void)) {
        loader.load(page: page) { result in
            if Thread.isMainThread {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
