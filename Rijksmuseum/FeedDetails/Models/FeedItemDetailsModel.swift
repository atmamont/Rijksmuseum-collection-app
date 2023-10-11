//
//  FeedItemDetailsViewModel.swift
//  Rijksmuseum
//
//  Created by Andrei on 11/10/2023.
//

import Foundation
import RijksmuseumFeed

final class FeedItemDetailsViewModel {
    private let model: FeedItem
    
    var title: String { model.title }
    //    var description: String { model.description }
    
    init(model: FeedItem) {
        self.model = model
    }
}
