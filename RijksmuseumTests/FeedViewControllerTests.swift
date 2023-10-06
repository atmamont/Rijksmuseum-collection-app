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
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Load is not expected on init")
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1, "Load is expected on viewDidLoad")
    }
    
    func test_pullToRefresh_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Pull to refresh should load feed")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Pull to refresh should load feed")
    }

    func test_loadCompletes_hidesLoadingIndicator() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoading()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
///    Thess tests do not work because of new behaviour of UIRefreshControl that ignores beginRefreshing() when off-screen

//    func test_userInitiatesReload_showsLoadingIndicator() {
//        let (sut, _) = makeSUT()
//        
//        sut.simulateUserInitiatedFeedReload()
//        
//        XCTAssertTrue(sut.isShowingLoadingIndicator)
//    }
//
//    func test_userInitiatesReload_hidesLoadingIndicatorOnLoadCompletion() {
//        let (sut, loader) = makeSUT()
//        
//        sut.simulateUserInitiatedFeedReload()
//        loader.completeLoading()
//        
//        XCTAssertFalse(sut.isShowingLoadingIndicator)
//    }

//    func test_load_showsLoadingIndicator() {
//        let (sut, loader) = makeSUT()
//        
//        let refreshControl = sut.collectionView.refreshControl
//
//        sut.loadViewIfNeeded()
//        
//        XCTAssertEqual(refreshControl?.isRefreshing, true)
//    }

    private func makeSUT() -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: #file, line: #line)
        trackForMemoryLeaks(sut, file: #file, line: #line)
        
        return (sut, loader)

    }
    
    private class LoaderSpy: FeedLoader {
        var loadCallCount: Int {
            completions.count
        }
        var completions = [(FeedLoader.Result) -> Void]()
        
        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            completions.append(completion)
        }
        
        func completeLoading(at index: Int = 0) {
            completions[index](.success([]))
        }
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?
                .forEach({ selectorName in
                    (target as NSObject).perform(Selector(selectorName))
            })
        })
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        collectionView.refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        collectionView.refreshControl?.isRefreshing ?? false
    }
}
