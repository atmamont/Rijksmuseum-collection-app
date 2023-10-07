//
//  FeedItemCell.swift
//  Rijksmuseum
//
//  Created by Andrei on 06/10/2023.
//

import UIKit
import RijksmuseumFeed

final class FeedItemCell: UICollectionViewCell {
    private(set) lazy var titleLabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .systemGray
        view.font = .systemFont(ofSize: 12)
        view.lineBreakMode = .byWordWrapping
        view.numberOfLines = 3
        view.textAlignment = .center
        return view
    }()
    private(set) lazy var titleContainer = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.addSubview(titleLabel, constraints: [
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        return view
    }()
    private(set) lazy var imageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    private(set) lazy var imageContainer = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.addFillingSubview(self.imageView)
        view.backgroundColor = .systemFill
        return view
    }()
    
    func configure(with model: FeedItem) {
        titleLabel.text = model.title
        
//        fadeIn(UIImage(named: model.imageName))
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .gray
        addFillingSubview(imageContainer)
        addSubview(titleContainer)
        NSLayoutConstraint.activate([
            titleContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            titleContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

