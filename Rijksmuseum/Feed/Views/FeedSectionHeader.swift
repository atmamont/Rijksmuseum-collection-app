//
//  FeedSectionHeader.swift
//  Rijksmuseum
//
//  Created by Andrei on 12/10/2023.
//

import UIKit

final class FeedSectionHeader: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let rootView = UIStackView(arrangedSubviews: [titleLabel, separator])
        rootView.translatesAutoresizingMaskIntoConstraints = false
        rootView.isLayoutMarginsRelativeArrangement = true
        rootView.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)
        rootView.spacing = 5
        rootView.axis = .vertical
        addFillingSubview(rootView)
    }
    
    //MARK: - Layout
    
    private(set) lazy var titleLabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 18)
        view.lineBreakMode = .byWordWrapping
        view.numberOfLines = 2
        return view
    }()
    
    private lazy var separator = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray
        let height = 1 / UIScreen.main.scale
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }()
}
