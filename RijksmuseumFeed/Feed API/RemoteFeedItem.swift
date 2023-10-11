//
//  RemoteFeedItem.swift
//  RijksmuseumFeed
//
//  Created by Andrei on 05/10/2023.
//

import Foundation

public struct RemoteFeedItem: Decodable {
    let id: String
    let objectNumber: String
    let title: String
    let longTitle: String
    let principalOrFirstMaker: String
    let webImage: RemoteImage
}

struct RemoteImage: Decodable {
    let url: URL
}

extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {
        map { $0.toModel() }
    }
}

extension RemoteFeedItem {
    func toModel() -> FeedItem {
        FeedItem(
            id: objectNumber,
            title: title,
            longTitle: longTitle,
            imageUrl: webImage.url,
            maker: principalOrFirstMaker)
    }
}
