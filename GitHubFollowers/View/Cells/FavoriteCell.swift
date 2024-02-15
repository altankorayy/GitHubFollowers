//
//  FavoriteCell.swift
//  GitHubFollowers
//
//  Created by Altan on 5.02.2024.
//

import UIKit

class FavoriteCell: UITableViewCell {

    static let identifier = "FavoriteCell"
    
    let avatarImageView = GFAvatarImageView(frame: .zero)
    let usernameLabel = GFTitleLabel(textAlignment: .left, fontSize: 26)
    
    let imageLoaderService: ImageLoaderService = ImageLoader()
    
    var cellIndexPath: IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
    
    private func configure() {
        addSubviews(avatarImageView, usernameLabel)
        accessoryType = .disclosureIndicator
        
        NSLayoutConstraint.activate([
            avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            
            usernameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 24),
            usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            usernameLabel.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    public func set(favorite: Follower, at indexPath: IndexPath) {
        usernameLabel.text = favorite.login
        Task {
            do {
                guard let imageData = try await imageLoaderService.downloadImage(favorite.avatar_url) else { return }
                guard indexPath == self.cellIndexPath else { return } //Avoid of wrong image displays
                let image = UIImage(data: imageData)
                self.avatarImageView.image = image
            } catch {
                self.avatarImageView.image = Images.placeholder
            }
        }
    }
}

//MARK: - Download Image (iOS < 15.0)
//        imageLoaderService.downloadImage(favorite.avatar_url) { [weak self] result in
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
//        }
      
