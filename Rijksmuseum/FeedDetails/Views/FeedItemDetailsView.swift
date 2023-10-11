//
//  FeedItemDetailsView.swift
//  Rijksmuseum
//
//  Created by Andrei on 11/10/2023.
//

import Foundation
import UIKit

final class FeedItemDetailsView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        addFillingSubview(rootView)
    }
    
    //MARK: - Layout
    private(set) lazy var rootView = {
        let view = UIStackView(arrangedSubviews: [imageContainer, titleLabel, makerLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 10
        view.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()

    private(set) lazy var titleLabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 20)
        view.lineBreakMode = .byWordWrapping
        view.numberOfLines = 0
        return view
    }()
    private(set) lazy var makerLabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 16)
        view.lineBreakMode = .byWordWrapping
        view.numberOfLines = 0
        return view
    }()
    private(set) lazy var imageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.alpha = 0
        return view
    }()
    private(set) lazy var imageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.addFillingSubview(imageView)
        return view
    }()

}
