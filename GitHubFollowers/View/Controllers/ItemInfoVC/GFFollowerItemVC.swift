//
//  GFFollowerItemVC.swift
//  GitHubFollowers
//
//  Created by Altan on 2.02.2024.
//

import UIKit

class GFFollowerItemVC: GFItemInfoVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureItems()
    }
    
    private func configureItems() {
        itemInfoViewFirst.set(itemInfoType: .followers, withCount: user.followers)
        itemInfoViewSecond.set(itemInfoType: .following, withCount: user.following)
        actionButton.set(backgroundColor: .systemGreen, title: "GitHub Followers")
    }

}
