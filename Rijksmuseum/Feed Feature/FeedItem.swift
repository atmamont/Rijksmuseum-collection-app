//
//  FeedItem.swift
//  Rijksmuseum
//
//  Created by Andrei on 03/10/2023.
//

import Foundation

public struct FeedItem {
    let id: UUID
    let title: String
    let imageUrl: URL
}

public typealias LoadFeedResult = Result<[FeedItem], Error>

public protocol FeedLoader {
    func load() -> LoadFeedResult
}
