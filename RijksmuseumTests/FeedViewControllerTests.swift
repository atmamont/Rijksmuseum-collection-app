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
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Load is not expected on init")
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1, "Load is expected on viewDidLoad")
    }
    
    private func makeSUT() -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: #file, line: #line)
        trackForMemoryLeaks(sut, file: #file, line: #line)
        
        return (sut, loader)

    }
    
    private class LoaderSpy: FeedLoader {
        var loadCallCount = 0
        
        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            loadCallCount += 1
        }
    }
}
