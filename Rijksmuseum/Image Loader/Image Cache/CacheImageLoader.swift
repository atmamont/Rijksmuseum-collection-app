//
//  CacheImageLoader.swift
//  Rijksmuseum
//
//  Created by Andrei on 09/10/2023.
//

import UIKit

public protocol ImageLoaderTask {
    func cancel()
}

public protocol ImageLoader {
    typealias Result = Swift.Result<UIImage, Error>
    
    func loadImage(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask
}

final class CacheImageLoader: ImageLoader {
    private let fallbackLoader: ImageDataLoader
    private let cache: ImageCaching
    
    init(cache: ImageCaching, fallbackLoader: ImageDataLoader) {
        self.cache = cache
        self.fallbackLoader = fallbackLoader
    }
    
    enum Error: Swift.Error {
        case noData
    }
    
    func loadImage(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask {
        let task = CacheTask()
        if let image = cache.image(for: url) {
            completion(.success(image))
        } else {
            let dataTask = fallbackLoader.loadImageData(from: url) { [weak cache] result in
                if let cache, let data = try? result.get(),
                   let image = UIImage.init(data: data) {
                    completion(.success(cache.insertImage(image, for: url)))
                } else {
                    completion(.failure(Error.noData))
                }
            }
            task.cancelCallback = {
                dataTask.cancel()
            }
        }
        return task
    }
    
    final class CacheTask: ImageLoaderTask {
        var cancelCallback: (() -> Void)?
        func cancel() {
            cancelCallback?()
        }
    }
}
