//
//  FeedItemLoaderMainThreadDispatcher.swift
//  RijksmuseumFeed
//
//  Created by Andrei on 11/10/2023.
//

import Foundation

public final class FeedItemLoaderMainThreadDispatcher: FeedItemLoader {
    let loader: FeedItemLoader
    
    public init(_ loader: FeedItemLoader) {
        self.loader = loader
    }
    
    public func load(objectNumber: String, completion: @escaping ((FeedItemLoader.Result) -> Void)) {
        loader.load(objectNumber: objectNumber) { result in
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

