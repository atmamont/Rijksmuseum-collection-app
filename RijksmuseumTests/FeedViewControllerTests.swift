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
        assertThat(sut, renders: [], inSection: 0)
        
        loader.completeFeedLoading(with: [item1])
        assertThat(sut, renders: [item1], inSection: 0)

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [item1, item2, item3])
        assertThat(sut, renders: [item1, item2, item3], inSection: 0)
    }
    
    func test_loadCompletion_doesNotBreakLoadedFeedOnReceivingLoadingError() {
        let (sut, loader) = makeSUT()
        let item1 = makeFeedItem(title: "Test item 1", imageUrl: anyURL())

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item1])
        assertThat(sut, renders: [item1], inSection: 0)

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: anyNSError())
        assertThat(sut, renders: [item1], inSection: 0)
    }
    
    private let indexPath00 = IndexPath(item: 0, section: 0)
    private let indexPath01 = IndexPath(item: 1, section: 0)
    private let indexPath02 = IndexPath(item: 2, section: 0)
    private let indexPath03 = IndexPath(item: 3, section: 0)
    private let indexPath04 = IndexPath(item: 4, section: 0)
    
    func test_feed_loadsImageUrlWhenVisible() {
        let (sut, loader) = makeSUT()
        let item1 = makeFeedItem(title: "Test item 1", imageUrl: anyURL())
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item1])
        XCTAssertEqual(loader.loadedImageUrls, [])
        
        sut.simulateFeedItemVisible(at: indexPath00)
        XCTAssertEqual(loader.loadedImageUrls, [item1.imageUrl])
    }
    
    func test_feed_cancelsLoadingImageUrlWhenCellBecomesInvisible() {
        let (sut, loader) = makeSUT()
        let item1 = makeFeedItem(title: "Test item 1", imageUrl: anyURL())
        let item2 = makeFeedItem(title: "Test item 2", imageUrl: URL(string: "https://another.url")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item1, item2])
        XCTAssertEqual(loader.canceledImageUrls, [])
        
        sut.simulateFeedItemNotVisible(at: indexPath00)
        XCTAssertEqual(loader.canceledImageUrls, [item1.imageUrl])
        
        sut.simulateFeedItemNotVisible(at: indexPath01)
        XCTAssertEqual(loader.canceledImageUrls, [item1.imageUrl, item2.imageUrl])
    }
    
    func test_feed_rendersImageLoadedFromURLWhenFeedItemIsNearlyVisible() {
        let (sut, loader) = makeSUT()
        let item1 = makeFeedItem(title: "Test item 1", imageUrl: anyURL())
        let item2 = makeFeedItem(title: "Test item 2", imageUrl: URL(string: "https://another.url")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item1, item2])
        XCTAssertEqual(loader.loadedImageUrls, [])
        
        sut.simulateFeedItemNearlyVisible(at: indexPath00)
        XCTAssertEqual(loader.loadedImageUrls, [item1.imageUrl])

        sut.simulateFeedItemNearlyVisible(at: indexPath01)
        XCTAssertEqual(loader.loadedImageUrls, [item1.imageUrl, item2.imageUrl])
        
        sut.simulateFeedItemNotNearlyVisible(at: indexPath01)
        XCTAssertEqual(loader.canceledImageUrls, [item2.imageUrl])

    }
    
    func test_feed_loadsMoreItemsOnReachingFeedEndRespectingOffset() {
        let (sut, loader) = makeSUT()
        let item1 = makeFeedItem(title: "Test item 1", imageUrl: anyURL())
        let item2 = makeFeedItem(title: "Test item 2", imageUrl: URL(string: "https://another.url")!)
        let item3 = makeFeedItem(title: "Test item 3", imageUrl: URL(string: "https://another.url")!)
        let item4 = makeFeedItem(title: "Test item 4", imageUrl: URL(string: "https://another.url")!)
        let item5 = makeFeedItem(title: "Test item 5", imageUrl: URL(string: "https://another.url")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item1, item2, item3, item4, item5])
        XCTAssertEqual(loader.requestFeedCallCount, 1)
        
        sut.simulateFeedItemWillBeDisplayed(at: indexPath02)
        XCTAssertEqual(loader.requestFeedCallCount, 1)

        sut.simulateFeedItemWillBeDisplayed(at: indexPath03)
        XCTAssertEqual(loader.requestFeedCallCount, 1)

        sut.simulateFeedItemWillBeDisplayed(at: indexPath04)
        XCTAssertEqual(loader.requestFeedCallCount, 2)
    }
    
    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.composeFeedViewController(
            feedLoader: loader,
            imageLoader: loader)
        
        trackForMemoryLeaks(loader, file: #file, line: #line)
        trackForMemoryLeaks(sut, file: #file, line: #line)
        
        return (sut, loader)
    }
    
    func assertThat(_ sut: FeedViewController, hasViewConfiguredForItem item: FeedItem, at indexPath: IndexPath, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedItemView(at: indexPath) as? FeedItemCell
        XCTAssertNotNil(view, file: file, line: line)
        XCTAssertEqual(view?.titleLabel.text, item.title, file: file, line: line)
    }
    
    func assertThat(_ sut: FeedViewController, renders items: [FeedItem], inSection section: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(items.count, sut.numberOfRenderedFeedItems(in: section))
        
        items.enumerated().forEach { index, item in
            assertThat(sut, hasViewConfiguredForItem: item, at: IndexPath(item: index, section: section))
        }
    }

    func makeFeedItem(title: String, imageUrl: URL, maker: String = "Maker1") -> FeedItem {
        FeedItem(id: UUID().uuidString, title: title, imageUrl: imageUrl, maker: maker)
    }
    
    private class LoaderSpy: FeedLoader, ImageLoader {
        var requestFeedCallCount: Int {
            requestFeedCompletions.count
        }
        var requestFeedCompletions = [(FeedLoader.Result) -> Void]()
        
        func load(page: Int = 1, completion: @escaping ((FeedLoader.Result) -> Void)) {
            requestFeedCompletions.append(completion)
        }
        
        func completeFeedLoading(with items: [FeedItem] = [], at index: Int = 0) {
            requestFeedCompletions[index](.success(items))
        }

        func completeFeedLoading(with error: Error, at index: Int = 0) {
            requestFeedCompletions[index](.failure(error))
        }
        
        // MARK: - ImageDataLoader
        private struct ImageLoaderTaskSpy: ImageLoaderTask {
            let callback: () -> Void
            func cancel() {
                callback()
            }
        }
        
        var imageRequests = [(url: URL, completion: (ImageLoader.Result) -> Void)]()
        var loadedImageUrls: [URL] {
            imageRequests.map { $0.url }
        }
        var canceledImageUrls = [URL]()
        
        func loadImage(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageLoaderTask {
            imageRequests.append((url: url, completion: completion))
            print("Loading image \(url)")
            
            return ImageLoaderTaskSpy { [weak self] in
                self?.canceledImageUrls.append(url)
            }
        }
        
        func completeImageLoading(with image: UIImage = UIImage(), at index: Int = 0) {
            imageRequests[index].completion(.success(image))
        }

        func completeImageLoading(with error: Error, at index: Int = 0) {
            imageRequests[index].completion(.failure(error))
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
    
    @discardableResult
    func simulateFeedItemVisible(at indexPath: IndexPath) -> FeedItemCell? {
        feedItemView(at: indexPath) as? FeedItemCell
    }
    
    func simulateFeedItemNotVisible(at indexPath: IndexPath) {
        let view = simulateFeedItemVisible(at: indexPath)
        
        let delegate = collectionView.delegate
        delegate?.collectionView?(collectionView, didEndDisplaying: view!, forItemAt: indexPath)
    }
    
    func simulateFeedItemNearlyVisible(at indexPath: IndexPath) {
        let ds = collectionView.prefetchDataSource
        ds?.collectionView(collectionView, prefetchItemsAt: [indexPath])
    }

    func simulateFeedItemNotNearlyVisible(at indexPath: IndexPath) {
        simulateFeedItemNearlyVisible(at: indexPath)
        
        let ds = collectionView.prefetchDataSource
        ds?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [indexPath])
    }
    
    func simulateFeedItemWillBeDisplayed(at indexPath: IndexPath) {
        let view = simulateFeedItemVisible(at: indexPath)
        let delegate = collectionView.delegate
        delegate?.collectionView?(collectionView, willDisplay: view!, forItemAt: indexPath)
    }

    var isShowingLoadingIndicator: Bool {
        collectionView.refreshControl?.isRefreshing ?? false
    }
    
    func numberOfRenderedFeedItems(in section: Int) -> Int {
        guard let ds = collectionView.dataSource,
              ds.numberOfSections!(in: collectionView) > 0 else { return 0 }
        
        return ds.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func feedItemView(at indexPath: IndexPath) -> UIView? {
        let ds = collectionView.dataSource
        let view = ds?.collectionView(collectionView, cellForItemAt: indexPath)
        return view
    }
}

private extension FeedItemCell {
    var isShowingLoadingIndicator: Bool {
        imageContainer.isShimmering
    }
    
    var renderedImageData: Data? {
        imageView.image?.pngData()
    }
}

private extension UIColor {
    func makeImage(_ size: CGSize = .init(width: 1.0, height: 1.0)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            self.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
