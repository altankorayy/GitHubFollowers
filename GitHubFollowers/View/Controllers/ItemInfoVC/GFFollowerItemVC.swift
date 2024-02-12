//
//  GFFollowerItemVC.swift
//  GitHubFollowers
//
//  Created by Altan on 2.02.2024.
//

import UIKit

protocol GFFollowerItemVCDelegate: AnyObject {
    func didTapGetFollowers(for user: User)
}

class GFFollowerItemVC: GFItemInfoVC {
    
    weak var delegate: GFFollowerItemVCDelegate?
    
    init(user: User, delegate: GFFollowerItemVCDelegate) {
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
        itemInfoViewFirst.set(itemInfoType: .followers, withCount: user.followers)
        itemInfoViewSecond.set(itemInfoType: .following, withCount: user.following)
        actionButton.set(backgroundColor: .systemGreen, title: "GitHub Followers")
    }
    
    override func actionButtonTapped() {
        delegate?.didTapGetFollowers(for: user)
    }

}
