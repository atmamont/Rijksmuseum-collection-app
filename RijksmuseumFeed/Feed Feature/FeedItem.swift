//
//  FeedItem.swift
//  Rijksmuseum
//
//  Created by Andrei on 03/10/2023.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let title: String
    let imageUrl: URL

    public init(id: UUID, title: String, imageUrl: URL) {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
    }
}

public typealias LoadFeedResult = Result<[FeedItem], Error>

public protocol FeedLoader {
    func load(completion: @escaping ((LoadFeedResult) -> Void))
}
