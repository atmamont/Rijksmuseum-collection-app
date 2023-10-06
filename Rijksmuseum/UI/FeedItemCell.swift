//
//  FeedItemCell.swift
//  Rijksmuseum
//
//  Created by Andrei on 06/10/2023.
//

import UIKit
import RijksmuseumFeed

final class FeedItemCell: UICollectionViewCell {
    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var imageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    private(set) lazy var imageContainer = UIView()
    
    func configure(with model: FeedItem) {
        titleLabel.text = model.title
        
//        fadeIn(UIImage(named: model.imageName))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.alpha = 0
        imageContainer.startShimmering()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.alpha = 0
        imageContainer.startShimmering()
    }
    
    private func fadeIn(_ image: UIImage?) {
        imageView.image = image
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.5,
            animations: {
                self.imageView.alpha = 1
            },
            completion: { _ in
                self.imageContainer.stopShimmering()
            })
    }
}

