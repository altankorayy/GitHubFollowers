//
//  TabBarController.swift
//  GitHubFollowers
//
//  Created by Altan on 17.01.2024.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchViewVC = UINavigationController(rootViewController: SearchVC())
        let favoritesVC = UINavigationController(rootViewController: FavoritesListVC())
        
        searchViewVC.tabBarItem.image = SFSymbols.searchVCTabBarImage
        favoritesVC.tabBarItem.image = SFSymbols.favoritesVCTabBarImage
        
        favoritesVC.navigationBar.prefersLargeTitles = true
        favoritesVC.navigationItem.largeTitleDisplayMode = .always
        
        searchViewVC.title = "Search"
        favoritesVC.title = "Favorites"
        
        tabBar.tintColor = .systemGreen
        
        setViewControllers([searchViewVC, favoritesVC], animated: true)
    }
    

}
