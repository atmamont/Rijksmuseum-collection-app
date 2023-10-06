//
//  FeedItemViewModel+Prototype.swift
//  Rijksmuseum
//
//  Created by Andrei on 06/10/2023.
//

import Foundation

extension FeedItemViewModel {
    static var prototypeFeed: [FeedItemViewModel] {
        [
            FeedItemViewModel(title: "De Nachtwacht", imageName: "image-0"),
            FeedItemViewModel(title: "Isaak en Rebekka, bekend als ‘Het Joodse bruidje", imageName: "image-1"),
            FeedItemViewModel(title: "De waardijns van het Amsterdamse lakenbereidersgilde, bekend als ‘De Staalmeesters’", imageName: "image-2"),
            FeedItemViewModel(title: "Portret van een vrouw, mogelijk Maria Trip", imageName: "image-3"),
            FeedItemViewModel(title: "Zelfportret als de apostel Paulus", imageName: "image-4")
        ]
        
    }
}
