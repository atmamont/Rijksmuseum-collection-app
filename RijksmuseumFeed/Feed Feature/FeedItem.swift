//
//  FeedItem.swift
//  Rijksmuseum
//
//  Created by Andrei on 03/10/2023.
//

import Foundation

public struct FeedItem: Equatable {
    public let id: String
    public let title: String
    public let imageUrl: URL

    public init(id: String, title: String, imageUrl: URL) {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
    }
}


public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedItem], Error>

    func load(completion: @escaping ((Result) -> Void))
}
