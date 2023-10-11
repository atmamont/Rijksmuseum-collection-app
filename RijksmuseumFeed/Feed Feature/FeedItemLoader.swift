//
//  FeedItemLoader.swift
//  RijksmuseumFeed
//
//  Created by Andrei on 11/10/2023.
//

import Foundation

public protocol FeedItemLoader {
    typealias Result = Swift.Result<FeedItem, Error>

    func load(objectNumber: String, completion: @escaping ((Result) -> Void))
}
