//
//  UIComposer.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import Foundation
import RijksmuseumFeed
import UIKit

final class UIComposer {
    static func makeFeedViewController() -> FeedViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.feedLoader = UIComposer.makeRemoteFeedLoader()
        return feedViewController
    }
    
    private static func makeRemoteFeedLoader() -> FeedLoader {
        RemoteFeedLoader(client: URLSessionHTTPClient())
    }
}
