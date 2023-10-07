//
//  RMAuthorizedHttpClient.swift
//  RijksmuseumFeed
//
//  Created by Andrei on 07/10/2023.
//

import Foundation

public final class RMAuthorizedHttpClient: HTTPClient {
    private let client: HTTPClient
    
    private var parameters: [String: String] {
        ["key": "0fiuZFh4"]
    }

    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        var url = url
        let queryItems = parameters.map(URLQueryItem.init)
        url.append(queryItems: queryItems)
        
        client.get(from: url, completion: completion)
    }
}
