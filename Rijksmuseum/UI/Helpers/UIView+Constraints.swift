//
//  UIView+Constraints.swift
//  Rijksmuseum
//
//  Created by Andrei on 07/10/2023.
//

import UIKit

extension UIView {
    func addFillingSubview(_ view: UIView) {
        addSubview(view)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func addSubview(_ view: UIView, constraints: [NSLayoutConstraint]) {
        addSubview(view)
        NSLayoutConstraint.activate(constraints)
    }
}
