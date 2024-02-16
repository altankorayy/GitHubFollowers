//
//  FollowersCell.swift
//  GitHubFollowers
//
//  Created by Altan on 21.01.2024.
//

import UIKit

final class FollowersCell: UICollectionViewCell {
    static let identifier = "FollowersCell"
    
    let avatarImageView = GFAvatarImageView(frame: .zero)
    let usernameLabel = GFTitleLabel(textAlignment: .center, fontSize: 16)
    var imageLoaderService: ImageLoaderService = ImageLoader()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.avatarImageView.image = nil
        self.usernameLabel.text = nil
    }
    
    func set(followers: Follower) {
        usernameLabel.text = followers.login
        
        Task {
            do {
                guard let imageData = try await imageLoaderService.downloadImage(followers.avatar_url) else { return }
                let image = UIImage(data: imageData)
                self.avatarImageView.image = image
            } catch {
                self.avatarImageView.image = Images.placeholder
            }
        }
        
//MARK: - Download Image (iOS < 15.0)
//        imageLoaderService?.downloadImage(followers.avatar_url, completion: { [weak self] result in
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let imageData):
//                let image = UIImage(data: imageData)
//
//                DispatchQueue.main.async {
//                    self.avatarImageView.image = image
//                }
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        })
    }
    
    private func configure() {
        addSubviews(avatarImageView, usernameLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            avatarImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            
            usernameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            usernameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            usernameLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
