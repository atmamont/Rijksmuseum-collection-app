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
        
        XCTAssertEqual(loader.requestFeedCallCount, 0, "Load is not expected on init")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.requestFeedCallCount, 1, "Load is expected on viewDidLoad")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.requestFeedCallCount, 2, "Pull to refresh should load feed")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.requestFeedCallCount, 3, "Pull to refresh should load feed")
    }

    func test_loadCompletes_hidesLoadingIndicator() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    func test_loadCompletion_rendersFeed() {
        let (sut, loader) = makeSUT()
        let item1 = makeFeedItem(title: "Test item 1", imageUrl: anyURL())
        let item2 = makeFeedItem(title: "Test item 2", imageUrl: anyURL())
        let item3 = makeFeedItem(title: "Test item 3", imageUrl: anyURL())

        sut.loadViewIfNeeded()
        assertThat(sut, renders: [])
        
        loader.completeFeedLoading(with: [item1])
        assertThat(sut, renders: [item1])

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [item1, item2, item3])
        assertThat(sut, renders: [item1, item2, item3])
    }
    
    func test_loadCompletion_doesNotBreakLoadedFeedOnReceivingLoadingError() {
        let (sut, loader) = makeSUT()
        let item1 = makeFeedItem(title: "Test item 1", imageUrl: anyURL())

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item1])
        assertThat(sut, renders: [item1])

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: anyNSError())
        assertThat(sut, renders: [item1])
    }
    
    func test_feed_loadsImageUrlWhenVisible() {
        let (sut, loader) = makeSUT()
        let item1 = makeFeedItem(title: "Test item 1", imageUrl: anyURL())
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item1])
        
        XCTAssertEqual(loader.loadedImageUrls, [])
    }

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader, imageLoader: loader)
        
        trackForMemoryLeaks(loader, file: #file, line: #line)
        trackForMemoryLeaks(sut, file: #file, line: #line)
        
        return (sut, loader)
    }
    
    func assertThat(_ sut: FeedViewController, hasViewConfiguredForItem item: FeedItem, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedItemView(at: index) as? FeedItemCell
        XCTAssertNotNil(view, file: file, line: line)
        XCTAssertEqual(view?.titleLabel.text, item.title, file: file, line: line)
    }
    
    func assertThat(_ sut: FeedViewController, renders items: [FeedItem], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(items.count, sut.numberOfRenderedFeedItems())
        
        items.enumerated().forEach { index, item in
            assertThat(sut, hasViewConfiguredForItem: item, at: index)
        }
    }

    func makeFeedItem(title: String, imageUrl: URL) -> FeedItem {
        FeedItem(id: UUID(), title: title, imageUrl: imageUrl)
    }
    
    private class LoaderSpy: FeedLoader, ImageDataLoader {
        var requestFeedCallCount: Int {
            requestFeedCompletions.count
        }
        var requestFeedCompletions = [(FeedLoader.Result) -> Void]()
        
        func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
            requestFeedCompletions.append(completion)
        }
        
        func completeFeedLoading(with items: [FeedItem] = [], at index: Int = 0) {
            requestFeedCompletions[index](.success(items))
        }

        func completeFeedLoading(with error: Error, at index: Int = 0) {
            requestFeedCompletions[index](.failure(error))
        }
        
        // MARK: - ImageDataLoader
        var loadedImageUrls = [URL]()
        
        func loadImageData(from url: URL) {
            loadedImageUrls.append(url)
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
    
    func simulateFeedItemVisible(at index: Int) {
        _ = feedItemView(at: index)
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
