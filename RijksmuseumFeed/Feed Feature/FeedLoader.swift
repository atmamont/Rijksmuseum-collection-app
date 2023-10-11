//
//  FeedLoader.swift
//  RijksmuseumFeed
//
//  Created by Andrei on 11/10/2023.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedItem], Error>

    func load(page: Int, completion: @escaping ((Result) -> Void))
}
