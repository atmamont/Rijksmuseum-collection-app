//
//  FeedViewControllerTests.swift
//  RijksmuseumTests
//
//  Created by Andrei on 06/10/2023.
//

import XCTest
import RijksmuseumFeed
@testable import Rijksmuseum

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0, "Load is not expected on init")
    }
    
    private class LoaderSpy: FeedLoader {
        var loadCallCount = 0
        
        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            loadCallCount += 1
        }
    }
}
