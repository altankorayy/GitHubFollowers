//
//  GFRepoItemInfoVC.swift
//  GitHubFollowers
//
//  Created by Altan on 2.02.2024.
//

import UIKit

protocol GFRepoItemInfoVCDelegate: AnyObject {
    func didTapGithubProfile(for user: User)
}

class GFRepoItemInfoVC: GFItemInfoVC {
    
    weak var delegate: GFRepoItemInfoVCDelegate?
    
    init(user: User, delegate: GFRepoItemInfoVCDelegate) {
        super.init(user: user)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureItems()
    }
    
    private func configureItems() {
        itemInfoViewFirst.set(itemInfoType: .repos, withCount: user.public_repos)
        itemInfoViewSecond.set(itemInfoType: .gist, withCount: user.public_gists)
        actionButton.set(color: .systemPink, title: "GitHub Profile")
    }
    
    override func actionButtonTapped() {
        delegate?.didTapGithubProfile(for: user)
    }

}
