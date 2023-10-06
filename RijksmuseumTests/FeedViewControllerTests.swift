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
        
        sut.simulateFeedItemVisible(at: 0)
        XCTAssertEqual(loader.loadedImageUrls, [item1.imageUrl])
    }
    
    func test_feed_cancelsLoadingImageUrlWhenCellBecomesInvisible() {
        let (sut, loader) = makeSUT()
        let item1 = makeFeedItem(title: "Test item 1", imageUrl: anyURL())
        let item2 = makeFeedItem(title: "Test item 2", imageUrl: URL(string: "https://another.url")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item1, item2])
        XCTAssertEqual(loader.canceledImageUrls, [])
        
        sut.simulateFeedItemNotVisible(at: 0)
        XCTAssertEqual(loader.canceledImageUrls, [item1.imageUrl])
        
        sut.simulateFeedItemNotVisible(at: 1)
        XCTAssertEqual(loader.canceledImageUrls, [item1.imageUrl, item2.imageUrl])
    }
    
    func test_feedLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        let item1 = makeFeedItem(title: "Test item 1", imageUrl: anyURL())
        let item2 = makeFeedItem(title: "Test item 2", imageUrl: URL(string: "https://another.url")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item1, item2])
        let view0 = sut.simulateFeedItemVisible(at: 0)
        let view1 = sut.simulateFeedItemVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingLoadingIndicator, true)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true)
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true)
        
        loader.completeImageLoading(with: anyNSError(), at: 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, false)
    }
    
    func test_feed_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        let item1 = makeFeedItem(title: "Test item 1", imageUrl: anyURL())
        let item2 = makeFeedItem(title: "Test item 2", imageUrl: URL(string: "https://another.url")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item1, item2])
        let view0 = sut.simulateFeedItemVisible(at: 0)
        let view1 = sut.simulateFeedItemVisible(at: 1)
        XCTAssertEqual(view0?.renderedImageData, .none)
        XCTAssertEqual(view1?.renderedImageData, .none)
        
        let imageData0 = UIImage(data: UIColor.white.makeImage().pngData()!)!.pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImageData, imageData0)
        XCTAssertEqual(view1?.renderedImageData, .none)

        let imageData1 = UIImage(data: UIColor.red.makeImage().pngData()!)!.pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImageData, imageData0)
        XCTAssertEqual(view1?.renderedImageData, imageData1)
    }

    func test_feed_rendersImageLoadedFromURLWhenFeedItesIsNearlyVisible() {
        let (sut, loader) = makeSUT()
        let item1 = makeFeedItem(title: "Test item 1", imageUrl: anyURL())
        let item2 = makeFeedItem(title: "Test item 2", imageUrl: URL(string: "https://another.url")!)
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item1, item2])
        XCTAssertEqual(loader.loadedImageUrls, [])
        
        sut.simulateFeedItemNearlyVisible(at: 0)
        XCTAssertEqual(loader.loadedImageUrls, [item1.imageUrl])

        sut.simulateFeedItemNearlyVisible(at: 1)
        XCTAssertEqual(loader.loadedImageUrls, [item1.imageUrl, item2.imageUrl])
        
        sut.simulateFeedItemNotNearlyVisible(at: 1)
        XCTAssertEqual(loader.canceledImageUrls, [item2.imageUrl])

    }
    
    // MARK: - Helpers

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
        private struct ImageDataLoaderTaskSpy: ImageDataLoaderTask {
            let callback: () -> Void
            func cancel() {
                callback()
            }
        }
        
        var imageRequests = [(url: URL, completion: (ImageDataLoader.Result) -> Void)]()
        var loadedImageUrls: [URL] {
            imageRequests.map { $0.url }
        }
        var canceledImageUrls = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
            imageRequests.append((url: url, completion: completion))
            
            return ImageDataLoaderTaskSpy { [weak self] in
                self?.canceledImageUrls.append(url)
            }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
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
    func simulateFeedItemVisible(at index: Int) -> FeedItemCell? {
        feedItemView(at: index) as? FeedItemCell
    }
    
    func simulateFeedItemNotVisible(at index: Int) {
        let view = simulateFeedItemVisible(at: index)
        
        let delegate = collectionView.delegate
        let indexPath = IndexPath(item: index, section: defaultSection())
        delegate?.collectionView?(collectionView, didEndDisplaying: view!, forItemAt: indexPath)
    }
    
    func simulateFeedItemNearlyVisible(at index: Int) {
        let ds = collectionView.prefetchDataSource
        let indexPath = IndexPath(item: index, section: defaultSection())
        ds?.collectionView(collectionView, prefetchItemsAt: [indexPath])
    }

    func simulateFeedItemNotNearlyVisible(at index: Int) {
        simulateFeedItemNearlyVisible(at: index)
        
        let ds = collectionView.prefetchDataSource
        let indexPath = IndexPath(item: index, section: defaultSection())
        ds?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [indexPath])
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
