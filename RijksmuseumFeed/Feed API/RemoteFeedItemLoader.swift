//
//  RemoteFeedItemLoader.swift
//  RijksmuseumFeed
//
//  Created by Andrei on 11/10/2023.
//

import Foundation

public final class RemoteFeedItemLoader: FeedItemLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func load(objectNumber: String, completion: @escaping (FeedItemLoader.Result) -> Void) {
        let requestUrl = API.baseUrl
            .appending(path: API.collectionRequestPath)
            .appending(path: objectNumber)
        
        client.get(from: requestUrl) { result in
            switch result {
            case let .success((remoteData, response)):
                completion(RemoteFeedItemLoader.map(remoteData, from: response))
            case .failure:
                completion(.failure(RemoteFeedLoader.Error.connectivity))
            }
        }
    }
    private static func map(_ data: Data, from response: HTTPURLResponse) -> FeedItemLoader.Result {
        do {
            let item = try RemoteFeedItemMapper.map(data, from: response)
            return .success(item.toModel())
        } catch {
            return .failure(error)
        }
    }
}

internal final class RemoteFeedItemMapper {
    private struct Root: Decodable {
        let artObject: RemoteFeedItem
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteFeedItem {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.artObject
    }
}
