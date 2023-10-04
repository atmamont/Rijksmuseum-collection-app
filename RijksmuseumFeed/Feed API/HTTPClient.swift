//
//  HTTPClient.swift
//  Rijksmuseum
//
//  Created by Andrei on 03/10/2023.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
