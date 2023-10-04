//
//  RemoteFeedLoaderTests.swift
//  RijksmuseumTests
//
//  Created by Andrei on 03/10/2023.
//

import XCTest
import RijksmuseumFeed

class RemoteFeedLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        
    }
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotTriggerServiceRequest() {
        let client = URLSessionHTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        
        XCTAssertEqual(client.getCallCount, 0)
    }
    
    
    
    private class URLSessionHTTPClientSpy: HTTPClient {
        var getCallCount = 0
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            getCallCount += 1
        }
    }
}
