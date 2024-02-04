//
//  FollowersListVM.swift
//  GitHubFollowers
//
//  Created by Altan on 20.01.2024.
//

import Foundation

protocol FollowersListVMOutput: AnyObject {
    func updateView(_ model: [Follower])
    func getUserInfo(_ model: User)
    func error(_ error: String)
    func emptyStateContol()
}

class FollowersListVM {
    
    private let userService: UserService
    weak var delegate: FollowersListVMOutput?
    
    var username: String
    var page = 1
    var paginationFinished: (() -> Void)?
    var fetchCounter = 1
    
    init(userService: UserService, username: String) {
        self.userService = userService
        self.username = username
    }
    
    public func fetchFollowers() {
        #warning("Spinner View")
        userService.getFollowers(for: username, page: page) { [weak self] result in
            switch result {
            case .success(let followers):
                self?.fetchCounter += 1
                
                if followers.isEmpty && self?.fetchCounter == 1 {
                    self?.delegate?.emptyStateContol()
                    return
                }
                
                if followers.count < 100 {
                    self?.paginationFinished?()
                }
                
                self?.delegate?.updateView(followers)
            case .failure(let error):
                self?.delegate?.error(error.rawValue)
            }
        }
    }
    
    public func getUserInfo() {
        userService.getUserInfo(for: username) { [weak self] result in
            switch result {
            case .success(let user):
                self?.delegate?.getUserInfo(user)
            case .failure(let error):
                self?.delegate?.error(error.localizedDescription)
            }
        }
    }
}
