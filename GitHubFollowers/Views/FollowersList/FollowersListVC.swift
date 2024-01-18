//
//  FollowersListVC.swift
//  GitHubFollowers
//
//  Created by Altan on 18.01.2024.
//

import UIKit

class FollowersListVC: UIViewController {
    
    private var username: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }

}
