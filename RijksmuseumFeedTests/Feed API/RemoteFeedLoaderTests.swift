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
            switch result {
            case .success:
                break
            case let .failure(error):
                completion(.failure(error))
            }
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
        
        XCTAssertEqual(client.requestedUrls, [expectedLoadRequestUrl], "Expected to perform request on load call")
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedUrls, [expectedLoadRequestUrl, expectedLoadRequestUrl])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let expectedError = NSError(domain: "any", code: 1)
        let exp = expectation(description: "Waiting for load completion")

        sut.load { result in
            switch result {
            case .success:
                XCTFail("Expected to receive an error")
            case let .failure(error):
                XCTAssertEqual((error as NSError), expectedError)
            }
            exp.fulfill()
        }
        
        client.completeWithError(expectedError)
        wait(for: [exp], timeout: 1.0)

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
        typealias Completion = (HTTPClient.Result) -> Void
        
        var getCallCount = 0
        var recordedRequests = [(url: URL, completion: Completion)]()
        var requestedUrls: [URL] {
            recordedRequests.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping Completion) {
            getCallCount += 1
            recordedRequests.append((url, completion))
        }
        
        func completeWithError(_ error: Error, at index: Int = 0) {
            recordedRequests[index].completion(.failure(error))
        }
    }
}
