//
//  RemoteFeedLoaderTests.swift
//  RijksmuseumTests
//
//  Created by Andrei on 03/10/2023.
//

import XCTest
import RijksmuseumFeed
import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let title: String
    let longTitle: String
    let principalOrFirstMaker: String
    let webImage: RemoteImage
    let headerImage: RemoteImage
}

struct RemoteImage: Decodable {
    let url: URL
}

class RemoteFeedLoader {
    private let client: HTTPClient
    private let baseUrl = URL(string: "https://www.rijksmuseum.nl")!
    private let requestPath = "/api/nl/collection"
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(completion: @escaping ((LoadFeedResult) -> Void)) {
        let requestUrl = baseUrl.appending(path: requestPath)
        client.get(from: requestUrl) { result in
            switch result {
            case let .success((remoteData, response)):
                completion(RemoteFeedLoader.map(remoteData, from: response))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> LoadFeedResult {
        do {
            let items = try RemoteFeedItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {
        map {
            FeedItem(
                id: $0.id,
                title: $0.title,
                imageUrl: $0.headerImage.url)
        }
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

    func test_load_deliversEmptyFeedWhenReceivingEpmtyResponseOnSuccess() {
        let (sut, client) = makeSUT()
        let expectedFeed: [FeedItem] = []
        let exp = expectation(description: "Waiting for load completion")

        sut.load { result in
            switch result {
            case let .success(response):
                XCTAssertEqual(response, expectedFeed)
            case let .failure(error):
                XCTFail("Expected to successfully receive \(expectedFeed), got error \(error) instead")
            }
            exp.fulfill()
        }
        
        let emptyData = makeItemsJSON([])
        client.complete(withStatusCode: 200, data: emptyData)
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
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["artObjects": items]
        return try! JSONSerialization.data(withJSONObject: json)
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

        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedUrls[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            recordedRequests[index].completion(.success((data, response)))
        }
    }
}
