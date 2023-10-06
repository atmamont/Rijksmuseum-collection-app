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

    func test_loadActions_triggerFeedLoad() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Load is not expected on init")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Load is expected on viewDidLoad")

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
    
    func test_loadCompletion_rendersFeed() {
        let (sut, loader) = makeSUT()
        let item1 = makeFeedItem(title: "Test item 1", imageUrl: anyURL())
        let item2 = makeFeedItem(title: "Test item 2", imageUrl: anyURL())
        let item3 = makeFeedItem(title: "Test item 3", imageUrl: anyURL())

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.numberOfRenderedFeedItems(), 0)
        
        loader.completeLoading(with: [item1])
        XCTAssertEqual(sut.numberOfRenderedFeedItems(), 1)
        assertThat(sut, hasViewConfiguredForItem: item1, at: 0, file: #file, line: #line)

        sut.simulateUserInitiatedFeedReload()
        loader.completeLoading(with: [item1, item2, item3])
        assertThat(sut, hasViewConfiguredForItem: item1, at: 0, file: #file, line: #line)
        assertThat(sut, hasViewConfiguredForItem: item2, at: 1, file: #file, line: #line)
        assertThat(sut, hasViewConfiguredForItem: item3, at: 2, file: #file, line: #line)
    }
    
    private func makeSUT() -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: #file, line: #line)
        trackForMemoryLeaks(sut, file: #file, line: #line)
        
        return (sut, loader)

    }
    
    func makeFeedItem(title: String, imageUrl: URL) -> FeedItem {
        FeedItem(id: UUID(), title: title, imageUrl: imageUrl)
    }
    
    func assertThat(_ sut: FeedViewController, hasViewConfiguredForItem item: FeedItem, at index: Int, file: StaticString, line: UInt) {
        let view = sut.feedItemView(at: index) as? FeedItemCell
        XCTAssertNotNil(view, file: file, line: line)
        XCTAssertEqual(view?.titleLabel.text, item.title, file: file, line: line)
    }
    
    private class LoaderSpy: FeedLoader {
        var loadCallCount: Int {
            completions.count
        }
        var completions = [(FeedLoader.Result) -> Void]()
        
        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            completions.append(completion)
        }
        
        func completeLoading(with items: [FeedItem] = [], at index: Int = 0) {
            completions[index](.success(items))
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
    
    func defaultSection() -> Int { 0 }
    
    func numberOfRenderedFeedItems() -> Int {
        collectionView(collectionView, numberOfItemsInSection: defaultSection())
    }
    
    func feedItemView(at index: Int) -> UIView? {
        let ds = collectionView.dataSource
        let indexPath = IndexPath(item: index, section: defaultSection())
        let view = ds?.collectionView(collectionView, cellForItemAt: indexPath)
        return view
    }
}
