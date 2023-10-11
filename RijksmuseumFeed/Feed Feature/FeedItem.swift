//
//  FeedItem.swift
//  Rijksmuseum
//
//  Created by Andrei on 03/10/2023.
//

import Foundation

public struct FeedItem: Equatable, Hashable {
    public let id: String
    public let title: String
    public let imageUrl: URL
    public let maker: String

    public init(id: String, title: String, imageUrl: URL, maker: String) {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
        self.maker = maker
    }
}
