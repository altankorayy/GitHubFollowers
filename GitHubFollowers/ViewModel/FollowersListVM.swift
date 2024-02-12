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
    func presentDefaultErrorDelegate()
    func emptyStateContol()
}

class FollowersListVM {
    
    private let userService: UserService?
    weak var delegate: FollowersListVMOutput?
    
    var username: String?
    var page = 1
    var paginationFinished: (() -> Void)?
    var fetchCounter = 0
    
    init(userService: UserService, username: String) {
        self.userService = userService
        self.username = username
    }
    
    public func fetchFollowers() {
        guard let username = username else { return }
        Task {
            do {
                guard let followers = try await userService?.getFollowers(for: username, page: page) else { return }
                self.fetchCounter += 1
                
                if followers.isEmpty && self.fetchCounter == 1 {
                    self.delegate?.emptyStateContol()
                    return
                }
                if followers.count < 100 {
                    self.paginationFinished?()
                }
                self.delegate?.updateView(followers)
            } catch {
                
                if let gfError = error as? GFError {
                    self.delegate?.error(gfError.rawValue)
                } else {
                    self.delegate?.presentDefaultErrorDelegate()
                }
            }
        }
        
//MARK: - Get Followers (iOS < 15.0)
//        userService.getFollowers(for: username, page: page) { [weak self] result in
//            switch result {
//            case .success(let followers):
//                self?.fetchCounter += 1
//
//                if followers.isEmpty && self?.fetchCounter == 1 {
//                    self?.delegate?.emptyStateContol()
//                    return
//                }
//
//                if followers.count < 100 {
//                    self?.paginationFinished?()
//                }
//
//                self?.delegate?.updateView(followers)
//            case .failure(let error):
//                self?.delegate?.error(error.rawValue)
//            }
//        }
    }
    
    public func getUserInfo() {
        guard let username = username else { return }
        Task {
            do {
                guard let user = try await userService?.getUserInfo(for: username) else { return }
                self.delegate?.getUserInfo(user)
            } catch {
                if let gfError = error as? GFError {
                    self.delegate?.error(gfError.rawValue)
                } else {
                    self.delegate?.presentDefaultErrorDelegate()
                }
            }
        }
    }
    
//MARK: - Get User Info (iOS < 15.0)
//    public func getUserInfo() {
//        userService.getUserInfo(for: username) { [weak self] result in
//            switch result {
//            case .success(let user):
//                self?.delegate?.getUserInfo(user)
//            case .failure(let error):
//                self?.delegate?.error(error.localizedDescription)
//            }
//        }
//    }
    
}
