//
//  ImageCache.swift
//  Rijksmuseum
//
//  Created by Andrei on 09/10/2023.
//

import UIKit

protocol ImageCaching: AnyObject {
    func image(for url: URL) -> UIImage?
    func insertImage(_ image: UIImage?, for url: URL)
    func removeImage(for url: URL)
}

final class MemoryImageCache: ImageCaching {
    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.totalCostLimit = config.memoryLimit
        return cache
    }()
    private let lock = NSLock()
    private let config: Config
    private var resizeBlock: ((_ image: UIImage, _ size: CGSize) -> UIImage)

    struct Config {
        let countLimit: Int
        let memoryLimit: Int
        let maxImageWidth: CGFloat // this of course shoould be done smarter depending on device size and layout type

        static let defaultConfig = Config(countLimit: 300, memoryLimit: 1024 * 1024 * 300, maxImageWidth: 300)
    }

    init(config: Config = Config.defaultConfig, resizeBlock: @escaping ((UIImage, CGSize) -> UIImage)) {
        self.config = config
        self.resizeBlock = resizeBlock
    }
    
    func resized(from size: CGSize) -> CGSize {
        let ratio = config.maxImageWidth / size.width
        let height = size.height * ratio
        return CGSize(width: config.maxImageWidth, height: height)
    }
}

extension MemoryImageCache {
    func insertImage(_ image: UIImage?, for url: URL) {
        guard let image = image else { return removeImage(for: url) }
        let cacheImage = resizeBlock(image, resized(from: image.size))

        lock.lock(); defer { lock.unlock() }
        imageCache.setObject(cacheImage as AnyObject, forKey: url as AnyObject, cost: cacheImage.diskSize)
    }

    func removeImage(for url: URL) {
        lock.lock(); defer { lock.unlock() }
        imageCache.removeObject(forKey: url as AnyObject)
    }
}

extension MemoryImageCache {
    func image(for url: URL) -> UIImage? {
        lock.lock(); defer { lock.unlock() }
        if let image = imageCache.object(forKey: url as AnyObject) as? UIImage {
            return image
        }
        return nil
    }
}

extension UIImage {
    func decodedAndResizedImage(newSize: CGSize) -> UIImage {
        guard let cgImage = cgImage else { return self }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: cgImage.bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.interpolationQuality = .high
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let decodedImage = context?.makeImage() else { return self }
        return UIImage(cgImage: decodedImage)
    }
    
    var diskSize: Int {
        Data(pngData() ?? Data()).count
    }
}
