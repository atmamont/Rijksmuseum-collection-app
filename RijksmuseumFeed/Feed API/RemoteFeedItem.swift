//
//  RemoteFeedItem.swift
//  RijksmuseumFeed
//
//  Created by Andrei on 05/10/2023.
//

import Foundation

public struct RemoteFeedItem: Decodable {
    let id: UUID
    let title: String
    let longTitle: String
    let principalOrFirstMaker: String
    let webImage: RemoteImage
    let headerImage: RemoteImage
}

struct RemoteImage: Decodable {
    let url: URL
}

extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {
        map {
            FeedItem(
                id: $0.id,
                title: $0.title,
                imageUrl: $0.headerImage.url)
        }
    }
}
