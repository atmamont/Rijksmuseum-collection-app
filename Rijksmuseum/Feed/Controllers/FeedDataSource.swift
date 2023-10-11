//
//  FeedDataSource.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import UIKit

final class FeedDataSource: UICollectionViewDiffableDataSource<Section, FeedCellController> {
    private var sectionedItems = [Section: [FeedCellController]]()
    private var sections: [Section] {
        sectionedItems.keys.map { $0 }.sorted()
    }
    
    func append(_ newItems: [FeedCellController]) {
        // TODO: Optimization - apply changes to existing snapshot instead of creating a new one
        
        let newSectionedItems = newItems.reduce(into: [Section: [FeedCellController]]()) { result, item in
            let section = Section(maker: item.viewModel.maker)
            var items: [FeedCellController] = result[section] ?? [FeedCellController]()
            items.append(item)
            result[section] = items
        }
        
        sectionedItems.merge(newSectionedItems) { current, new in
            var result = current
            result.append(contentsOf: new)
            return result
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, FeedCellController>()
        snapshot.appendSections(sections)

        sections.forEach {
            snapshot.appendItems(sectionedItems[$0] ?? [], toSection: $0)
        }
        apply(snapshot, animatingDifferences: false)
    }
    
    func reset() {
        sectionedItems = [:]
        apply(.init())
    }
}

struct Section: Hashable, Comparable {
    static func < (lhs: Section, rhs: Section) -> Bool {
        lhs.maker < rhs.maker
    }
    
    let maker: String
}
