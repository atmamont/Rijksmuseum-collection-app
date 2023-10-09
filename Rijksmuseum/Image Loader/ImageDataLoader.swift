//
//  ImageDataLoader.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import Foundation

protocol ImageDataLoaderTask {
    func cancel()
}

protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageDataLoaderTask
}
