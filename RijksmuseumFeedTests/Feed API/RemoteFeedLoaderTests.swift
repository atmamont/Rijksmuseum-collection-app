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
    typealias Result = Swift.Result<[FeedItem], Swift.Error>
    
    private let client: HTTPClient
    private let baseUrl = URL(string: "https://www.rijksmuseum.nl")!
    private let requestPath = "/api/nl/collection"
    
    enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(completion: @escaping (Result) -> Void) {
        let requestUrl = baseUrl.appending(path: requestPath)
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
        
        expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.connectivity)) {
            client.completeWithError(NSError(domain: "A random connectivityt error", code: 1))
        }
    }

    func test_load_deliversEmptyFeedWhenReceivingEpmtyResponseOnSuccess() {
        let (sut, client) = makeSUT()
        let expectedEmptyFeed = [FeedItem]()
        
        expect(sut, toCompleteWith: .success(expectedEmptyFeed)) {
            let emptyData = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyData)
        }
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

    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
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
