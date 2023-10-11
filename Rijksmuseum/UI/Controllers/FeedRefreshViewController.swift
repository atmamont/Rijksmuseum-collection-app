//
//  FeedRefreshViewController.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import UIKit

final class FeedRefreshViewController: UIViewController {
    private(set) lazy var refreshControl = binded(UIRefreshControl())
    
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = refreshControl
    }
    
    @objc func load(page: Int = 1) {
        viewModel.loadFeed(page: page)
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.refreshControl.beginRefreshing()
            } else {
                self?.refreshControl.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(load), for: .valueChanged)
        return view
    }
}
