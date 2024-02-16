//
//  GFAvatarImageView.swift
//  GitHubFollowers
//
//  Created by Altan on 21.01.2024.
//

import UIKit

final class GFAvatarImageView: UIImageView {
    
    let placeholderImage = Images.placeholder

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeholderImage
        contentMode = .scaleAspectFit
        translatesAutoresizingMaskIntoConstraints = false
    }

}
