//
//  FeedItemCell.swift
//  Rijksmuseum
//
//  Created by Andrei on 06/10/2023.
//

import UIKit

final class FeedItemCell: UICollectionViewCell {
    @IBOutlet private(set) var title: UILabel!
    @IBOutlet private(set) var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFill
        }
    }
    
    func configure(with model: FeedItemViewModel) {
        title.text = model.title
        imageView.image = UIImage(named: model.imageName)
    }
}
