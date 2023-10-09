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
    
    private var items = [FeedCellController]()
    
    private var sectionedItems = [Section: [FeedCellController]]()
    private var sections: [Section] {
        sectionedItems.keys.map { $0 }.sorted()
    }
    
    func append(_ newItems: [FeedCellController]) {
        // TODO: Optimization - apply changes to existing snapshot instead of creating a new one
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
}
