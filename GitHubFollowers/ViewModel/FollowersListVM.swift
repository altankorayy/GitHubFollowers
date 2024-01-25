//
//  FollowersListVM.swift
//  GitHubFollowers
//
//  Created by Altan on 20.01.2024.
//

import Foundation

protocol FollowersListVMOutput: AnyObject {
    func updateView(_ model: [Follower])
    func error(_ error: String)
    func emptyStateContol()
}

class FollowersListVM {
    
    private let userService: UserService
    weak var delegate: FollowersListVMOutput?
    
    private var username: String
    var page = 1
    var paginationFinished: (() -> Void)?
    
    init(userService: UserService, username: String) {
        self.userService = userService
        self.username = username
    }
    
    
    public func fetchFollowers() {
        #warning("Spinner View")
        userService.getFollowers(for: username, page: page) { [weak self] result in
            switch result {
            case .success(let followers):
                
                if followers.count < 100 {
                    self?.paginationFinished?()
                }
                
                if followers.isEmpty {
                    self?.delegate?.emptyStateContol()
                }
                
                self?.delegate?.updateView(followers)
            case .failure(let error):
                self?.delegate?.error(error.rawValue)
            }
        }
    }
}
