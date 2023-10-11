//
//  FeedItemViewModel.swift
//  Rijksmuseum
//
//  Created by Andrei on 11/10/2023.
//

import Foundation
import RijksmuseumFeed
import UIKit

final class FeedItemViewModel {
    private(set) var model: FeedItem
    private let imageLoader: ImageLoader
    private var task: ImageLoaderTask?

    var id: String { model.id }
    var title: String { model.title }
    var maker: String { model.maker }

    var onImageLoad: Observer<UIImage>?
    var onImageLoadStateChange: Observer<Bool>?
    
    init(model: FeedItem, imageLoader: ImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func loadImage() {
        onImageLoadStateChange?(true)
        self.task = imageLoader.loadImage(from: model.imageUrl) { [weak self] result in
            self?.handle(result)
        }
    }
    
    func cancelImageLoad() {
        task?.cancel()
    }
    
    private func handle(_ result: ImageLoader.Result) {
        onImageLoadStateChange?(false)
        if let image = try? result.get() {
            onImageLoad?(image)
        }
    }
}
