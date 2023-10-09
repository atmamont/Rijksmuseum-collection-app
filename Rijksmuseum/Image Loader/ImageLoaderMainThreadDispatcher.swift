//
//  ImageLoaderMainThreadDispatcher.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import Foundation
import RijksmuseumFeed

final class ImageLoaderMainThreadDispatcher: ImageLoader {
    private let imageLoader: ImageLoader

    init(imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
    }

    func loadImage(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask {
        imageLoader.loadImage(from: url) { result in
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
