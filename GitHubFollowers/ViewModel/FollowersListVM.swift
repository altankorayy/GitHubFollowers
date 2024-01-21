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
}

class FollowersListVM {
    
    private let userService: UserService
    weak var delegate: FollowersListVMOutput?
    private var username: String
    
    init(userService: UserService, username: String) {
        self.userService = userService
        self.username = username
    }
    
    public func fetchFollowers() {
        
        userService.getFollowers(for: username, page: 1) { [weak self] result in
            switch result {
            case .success(let followers):
                guard let followers = followers else { return }
                self?.delegate?.updateView(followers)
            case .failure(let error):
                self?.delegate?.error(error.localizedDescription)
            }
        }
    }
}
