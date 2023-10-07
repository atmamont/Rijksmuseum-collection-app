//
//  RemoteImageDataLoaderMainThreadDispatcher.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import Foundation
import RijksmuseumFeed

final class RemoteImageDataLoaderMainThreadDispatcher: ImageDataLoader {
    private let imageLoader: ImageDataLoader
    
    init(imageLoader: ImageDataLoader) {
        self.imageLoader = imageLoader
    }

    func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
        imageLoader.loadImageData(from: url) { result in
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
