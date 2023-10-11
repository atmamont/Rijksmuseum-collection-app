//
//  RemoteFeedLoader.swift
//  RijksmuseumFeed
//
//  Created by Andrei on 05/10/2023.
//

import Foundation

public class RemoteFeedLoader: FeedLoader {
    public typealias Result = Swift.Result<[FeedItem], Swift.Error>
    
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func load(page: Int = 0, completion: @escaping (Result) -> Void) {
        var requestUrl = APISettings.baseUrl.appending(path: APISettings.collectionRequestPath)
        requestUrl.append(queryItems: makeQueryItems(page: page))
        client.get(from: requestUrl) { result in
            switch result {
            case let .success((remoteData, response)):
                completion(RemoteFeedLoader.map(remoteData, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try RemoteFeedItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
    
    private func makeQueryItems(page: Int) -> [URLQueryItem] {
        return [URLQueryItem(name: "imgonly", value: "true"),
                URLQueryItem(name: "p", value: "\(page)"),
                URLQueryItem(name: "s", value: "artist")]
    }
}

internal final class RemoteFeedItemsMapper {
    private struct Root: Decodable {
        let artObjects: [RemoteFeedItem]
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return root.artObjects
    }
}
