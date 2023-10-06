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
    @IBOutlet private(set) var imageContainer: UIView!
    
    func configure(with model: FeedItemViewModel) {
        title.text = model.title
        fadeIn(UIImage(named: model.imageName))
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

private extension UIView {
    private var shimmerAnimationKey: String {
        return "shimmer"
    }

    func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        let width = bounds.width
        let height = bounds.height

        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        layer.mask = gradient

        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmerAnimationKey)
    }

    func stopShimmering() {
        layer.mask = nil
    }
}
