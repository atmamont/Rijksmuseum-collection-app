//
//  SceneDelegate.swift
//  Rijksmuseum
//
//  Created by Andrei on 03/10/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: scene)

        let feedViewController = FeedUIComposer.makeFeedViewController()
        let rootViewController = UINavigationController(rootViewController: feedViewController)

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.window = window
    }
}
