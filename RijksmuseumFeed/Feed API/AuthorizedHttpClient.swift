//
//  RMAuthorizedHttpClient.swift
//  RijksmuseumFeed
//
//  Created by Andrei on 07/10/2023.
//

import Foundation

public final class AuthorizedHttpClient: HTTPClient {
    private let client: HTTPClient
    private let key: String
    
    private lazy var parameters: [String: String] = {
        ["key": self.key]
    }()
    
    public init(_ client: HTTPClient, authorizationKey: String) {
        self.client = client
        self.key = authorizationKey
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        var url = url
        let queryItems = parameters.map(URLQueryItem.init)
        url.append(queryItems: queryItems)
        
        client.get(from: url, completion: completion)
    }
}
