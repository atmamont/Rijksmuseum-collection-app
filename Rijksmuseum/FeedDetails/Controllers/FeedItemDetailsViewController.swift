//
//  FeedItemDetailsViewController.swift
//  Rijksmuseum
//
//  Created by Andrei on 11/10/2023.
//

import Foundation
import UIKit

final class FeedItemDetailsViewController: UIViewController {
    private let viewModel: FeedItemDetailsViewModel
    
    init(viewModel: FeedItemDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addFillingSubview(binded(contentView))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.backgroundColor = .systemBackground
        viewModel.load()
    }
    
    func binded(_ view: FeedItemDetailsView) -> FeedItemDetailsView {
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.imageContainer.startShimmering()
            } else {
                view?.imageContainer.stopShimmering()
            }
        }
        viewModel.onChange = { [weak self, weak view] viewModel in
            view?.titleLabel.text = viewModel.title
            view?.makerLabel.text = viewModel.maker
            self?.title = viewModel.title
        }
        viewModel.onImageLoad = { [weak view] image in
            guard let view else { return }
            UIView.animate(withDuration: 0.1) {
                view.imageView.alpha = 1
                view.imageView.image = image.preparingThumbnail(of: view.imageView.bounds.size)
            }
            
        }
        return view
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    lazy var contentView: FeedItemDetailsView = {
        let view = FeedItemDetailsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
