//
//  TabBarController.swift
//  GitHubFollowers
//
//  Created by Altan on 17.01.2024.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchViewVC = UINavigationController(rootViewController: SearchVC())
        let favoritesVC = UINavigationController(rootViewController: FavoritesListVC())
        
        searchViewVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        favoritesVC.tabBarItem.image = UIImage(systemName: "star")
        
        favoritesVC.navigationBar.prefersLargeTitles = true
        favoritesVC.navigationItem.largeTitleDisplayMode = .always
        
        searchViewVC.title = "Search"
        favoritesVC.title = "Favorites"
        
        tabBar.tintColor = .systemGreen
        
        setViewControllers([searchViewVC, favoritesVC], animated: true)
    }
    

}
