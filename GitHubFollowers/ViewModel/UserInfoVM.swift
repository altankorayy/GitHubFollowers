//
//  UserInfoVM.swift
//  GitHubFollowers
//
//  Created by Altan on 30.01.2024.
//

import Foundation

protocol UserInfoOutput: AnyObject {
    func updateView(_ model: User)
    func error(_ error: String)
}

class UserInfoVM {
    
    private let userService: UserService
    var username: String
    
    weak var delegate: UserInfoOutput?
    
    init(userService: UserService, username: String) {
        self.userService = userService
        self.username = username
    }
    
    func getUserInfo() {
        userService.getUserInfo(for: username) { [weak self] result in
            switch result {
            case .success(let user):
                self?.delegate?.updateView(user)
            case .failure(let error):
                self?.delegate?.error(error.localizedDescription)
            }
        }
    }
}
