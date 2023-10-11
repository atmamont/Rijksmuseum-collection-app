//
//  FeedItemDetailsViewModel.swift
//  Rijksmuseum
//
//  Created by Andrei on 11/10/2023.
//

import Foundation
import RijksmuseumFeed
import UIKit

final class FeedItemDetailsViewModel {
    private let objectNumber: String
    private let loader: FeedItemLoader
    private let imageLoader: ImageLoader
    private var task: ImageLoaderTask?

    var onLoadingStateChange: Observer<Bool>?
    var onImageLoadStateChange: Observer<Bool>?
    var onChange: Observer<FeedItemDetailsViewModel>?
    var onImageLoad: Observer<UIImage>?
    
    private var model: FeedItem? {
        didSet {
            onChange?(self)
        }
    }
    
    var title: String? { model?.title }
    var maker: String? { model?.maker }
    
    init(objectNumber: String, loader: FeedItemLoader, imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
        self.objectNumber = objectNumber
        self.loader = loader
    }
    
    func load() {
        onLoadingStateChange?(true)
        loader.load(objectNumber: objectNumber) { [weak self] result in
            self?.onLoadingStateChange?(false)
            
            if let feedItem = try? result.get() {
                self?.model = feedItem
                self?.loadImage(url: feedItem.imageUrl)
            }
        }
    }
    
    private func loadImage(url: URL) {
        onImageLoadStateChange?(true)
        self.task = imageLoader.loadImage(from: url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: ImageLoader.Result) {
        onImageLoadStateChange?(false)
        if let image = try? result.get() {
            onImageLoad?(image)
        }
    }
}
