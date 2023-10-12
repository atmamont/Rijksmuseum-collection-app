//
//  RemoteFeedLoaderTests.swift
//  RijksmuseumTests
//
//  Created by Andrei on 03/10/2023.
//

import XCTest
import RijksmuseumFeed
import Foundation

final class RemoteFeedLoaderTests: XCTestCase {

    private let expectedLoadRequestUrl = URL(string: "https://www.rijksmuseum.nl/api/nl/collection?imgonly=true&p=0&s=artist")

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
            client.completeWithError(NSError(domain: "A random connectivity error", code: 1))
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
    
    func test_load_deliversInvalidDataErrorWhenReceivingResponseWithNon200StatusCode() {
        let (sut, client) = makeSUT()
        
        let errorCodeResponses = [199, 201, 300, 400, 404, 500]
        
        errorCodeResponses.enumerated().forEach { index, value in
            expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData), when: {
                let jsonData = makeItemsJSON([])
                client.complete(withStatusCode: value, data: jsonData, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    func test_load_deliversFeedOn200HTTPResponseWithValidJSON() {
        let (sut, client) = makeSUT()
        let items = [
            makeItem(title: "De Nachtwacht",
                     longTitle: "De Nachtwacht, Rembrandt van Rijn, 1642",
                     principalOrFirstMaker: "Rembrandt van Rijn",
                     imageUrl: URL(string: "http://an-image-1.url")!),
            makeItem(title: "Sunflowers", 
                     longTitle: "Sunflowers, Vincent Van Gogh, 1889",
                     principalOrFirstMaker: "Vincent Van Gogh",
                     imageUrl: URL(string: "http://an-image-2.url")!)
        ]
        let models = items.map { $0.item }
        let itemsJson = makeItemsJSON(items.map { $0.json})
        
        expect(sut, toCompleteWith: .success(models), when: {
            client.complete(withStatusCode: 200, data: itemsJson)
        })
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
    
    private func makeItem(title: String, longTitle: String, principalOrFirstMaker: String, imageUrl: URL) -> (item: FeedItem, json: [String: Any]) {
        let id = UUID().uuidString
        let item = FeedItem(id: id, title: title, longTitle: longTitle, imageUrl: imageUrl, maker: principalOrFirstMaker)
        
        let json = [
            "objectNumber": id,
            "title": title,
            "longTitle": longTitle,
            "principalOrFirstMaker": principalOrFirstMaker,
            "webImage": ["url": imageUrl.absoluteString],
            "headerImage": ["url": imageUrl.absoluteString]
        ].reduce(into: [String: Any]()) { (acc, e) in
            acc[e.key] = e.value
        }
        
        return (item, json)
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
}
