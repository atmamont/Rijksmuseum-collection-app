//
//  ImageResizer.swift
//  Rijksmuseum
//
//  Created by Andrei on 09/10/2023.
//

import UIKit

struct ImageResizer {
    static func decodeAndResize(_ image: UIImage, size: CGSize) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: cgImage.bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.interpolationQuality = .high
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let decodedImage = context?.makeImage() else { return image }
        return UIImage(cgImage: decodedImage)
    }
}
