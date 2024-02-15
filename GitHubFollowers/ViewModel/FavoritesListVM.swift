//
//  FavoritesListVM.swift
//  GitHubFollowers
//
//  Created by Altan on 15.02.2024.
//

import Foundation

protocol FavoritesListVMOutput: AnyObject {
    func updateView(with favorites: [Follower])
    func updateWithError(with error: String)
    func showActivityIndicator(_ state: Bool)
}

class FavoritesListVM {
    
    weak var delegate: FavoritesListVMOutput?
    
    public func getFavorites() {
        delegate?.showActivityIndicator(true)
        PersistanceManager.retrieveFavorites { [weak self] result in
            switch result {
            case .success(let favorites):
                self?.delegate?.updateView(with: favorites)
                self?.delegate?.showActivityIndicator(false)
            case .failure(let error):
                self?.delegate?.showActivityIndicator(false)
                self?.delegate?.updateWithError(with: error.rawValue)
            }
        }
    }
}
