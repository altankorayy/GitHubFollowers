//
//  FavoritesListVC.swift
//  GitHubFollowers
//
//  Created by Altan on 17.01.2024.
//

import UIKit

final class FavoritesListVC: GFDataLoadingVC {
    
    let tableView = UITableView()
    var favorites: [Follower] = []
    
    private let viewModel = FavoritesListVM()
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureTableView()
        configureRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateWithFavorites()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.identifier)
        tableView.refreshControl = self.refreshControl
        tableView.frame = view.bounds
    }
    
    private func configureViewController() {
        title = "Favorites"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
    }
    
    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    private func updateWithFavorites() {
        viewModel.delegate = self
        viewModel.getFavorites()
    }
    
    @objc
    private func didPullToRefresh() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
}

extension FavoritesListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.identifier, for: indexPath) as? FavoriteCell else {
            return UITableViewCell()
        }
        let favorite = favorites[indexPath.row]
        cell.cellIndexPath = indexPath
        cell.set(favorite: favorite, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let favorite = favorites[indexPath.row]
        let userService: UserService = NetworkManager()
        let followersListVM = FollowersListVM(userService: userService, username: favorite.login)
        let destinationVC = FollowersListVC(viewModel: followersListVM)
        destinationVC.title = favorite.login
        navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let favorite = favorites[indexPath.row]
            
            PersistanceManager.updateWith(favorite: favorite, actionType: .remove) { [weak self] error in
                guard let self else { return }
                
                guard let error else {
                    self.favorites.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                    
                    if self.favorites.isEmpty {
                        self.showEmptyStateView(with: "No Favorites?\nAdd one on the follower screen.", in: self.view)
                    }
                    return
                }
                self.presentGFAlertOnMainThread(title: "Unable to remove", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
}

extension FavoritesListVC: FavoritesListVMOutput {
    func updateView(with favorites: [Follower]) {
        if favorites.isEmpty {
            self.showEmptyStateView(with: "No Favorites?\nAdd one on the follower screen.", in: self.view)
        } else {
            self.favorites = favorites
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.view.bringSubviewToFront(self.tableView)
            }
        }
    }
    
    func updateWithError(with error: String) {
        presentGFAlertOnMainThread(title: "Something went wrong", message: error, buttonTitle: "OK")
    }
    
    func showActivityIndicator(_ state: Bool) {
        if state {
            showSpinnerView()
        } else {
            dismissSpinnerView()
        }
    }
}
