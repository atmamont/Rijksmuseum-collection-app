//
//  HTTPClientSpy.swift
//  RijksmuseumFeedTests
//
//  Created by Andrei on 11/10/2023.
//

import Foundation
import RijksmuseumFeed

class HTTPClientSpy: HTTPClient {
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
