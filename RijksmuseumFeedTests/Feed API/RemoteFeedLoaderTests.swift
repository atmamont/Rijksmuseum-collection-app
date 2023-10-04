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
    private let baseUrl = URL(string: "https://www.rijksmuseum.nl")!
    private let requestPath = "/api/nl/collection"
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(completion: @escaping ((LoadFeedResult) -> Void)) {
        let requestUrl = baseUrl.appending(path: requestPath)
        client.get(from: requestUrl) { result in
            
        }
    }
}

final class RemoteFeedLoaderTests: XCTestCase {

    private let expectedLoadRequestUrl = URL(string: "https://www.rijksmuseum.nl/api/nl/collection")

    func test_init_doesNotTriggerServiceRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.getCallCount, 0)
    }
    
    func test_load_performsRequest() {
        let (sut, client) = makeSUT()

        sut.load { _ in }
        
        XCTAssertEqual(client.requestedPaths, [expectedLoadRequestUrl], "Expected to perform request on load call")
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedPaths, [expectedLoadRequestUrl, expectedLoadRequestUrl])
    }

    // MARK: - Helpers
    
    private func makeSUT() -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        
        return (sut, client)

    }
    
    private class HTTPClientSpy: HTTPClient {
        var getCallCount = 0
        var requestedPaths = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            getCallCount += 1
            requestedPaths.append(url)
        }
    }
}
