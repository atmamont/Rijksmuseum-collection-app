//
//  APISettings.swift
//  RijksmuseumFeed
//
//  Created by Andrei on 11/10/2023.
//

import Foundation

struct APISettings {
    static let baseUrl = URL(string: "https://www.rijksmuseum.nl")!
    static let collectionRequestPath = "/api/nl/collection"
}
