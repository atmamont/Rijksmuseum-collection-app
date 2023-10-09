//
//  FeedDataSource.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import RijksmuseumFeed
import UIKit

struct Section: Hashable, Comparable {
    static func < (lhs: Section, rhs: Section) -> Bool {
        lhs.maker < rhs.maker
    }
    
    let maker: String
}

final class FeedDataSource: UICollectionViewDiffableDataSource<Section, FeedCellController> {
    
    private var items = [FeedCellController]() {
        didSet {
            print(items.count)
        }
    }
    
    var sectionedItems = [Section: [FeedCellController]]()
    
    var sections: [Section] {
        sectionedItems.keys.map { $0 }.sorted()
    }
    
    func append(_ newItems: [FeedCellController]) {
        // TODO: Use items array changes not full dataset
        self.items.append(contentsOf: newItems)
        
        self.sectionedItems = items.reduce(into: [:]) { result, item in
            let section = Section(maker: item.model.maker)
            var items = result[section] ?? [FeedCellController]()
            items.append(item)
            result[section] = items
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, FeedCellController>()
        snapshot.appendSections(sections)

        sections.forEach {
            snapshot.appendItems(sectionedItems[$0] ?? [], toSection: $0)
        }
        apply(snapshot, animatingDifferences: false)
    }
    
    func reset() {
        items = []
    }
        
    private func makeSections(from items: [FeedCellController]) -> [Section] {
        let authors = items.map { $0.model.maker }
        return Set(authors).map(Section.init)
    }
    
    private func items(in section: Section) -> [FeedCellController] {
        let items = items.filter { $0.model.maker == section.maker }
        return items
    }
    
    func isLastItemInLastSection(_ item: FeedCellController) -> Bool {
        guard let lastSection = sections.last else { return false }
        return sectionedItems[lastSection]?.last == item
    }
}
