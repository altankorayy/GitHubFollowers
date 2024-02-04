//
//  GFRepoItemInfoVC.swift
//  GitHubFollowers
//
//  Created by Altan on 2.02.2024.
//

import UIKit

class GFRepoItemInfoVC: GFItemInfoVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureItems()
    }
    
    private func configureItems() {
        itemInfoViewFirst.set(itemInfoType: .repos, withCount: user.public_repos)
        itemInfoViewSecond.set(itemInfoType: .gist, withCount: user.public_gists)
        actionButton.set(backgroundColor: .systemPink, title: "GitHub Profile")
    }
    
    override func actionButtonTapped() {
        delegate?.didTapGithubProfile(for: user)
    }

}
