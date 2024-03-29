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
}

protocol StateHandling: AnyObject {
    func presentDefaultErrorDelegate()
    func emptyStateContol()
    func showActivityIndicator(_ state: Bool)
}

final class FollowersListVM {
    
    private let userService: UserService
    weak var delegate: FollowersListVMOutput?
    weak var stateHandlingDelegate: StateHandling?
    
    var username: String
    var page = 1
    var paginationFinished: (() -> Void)?
    var fetchCounter = 0
    
    init(userService: UserService, username: String) {
        self.userService = userService
        self.username = username
    }
    
    public func fetchFollowers() {
        stateHandlingDelegate?.showActivityIndicator(true)
        Task {
            do {
                let followers = try await userService.getFollowers(for: username, page: page)
                self.fetchCounter += 1
                
                if followers.isEmpty && self.fetchCounter == 1 {
                    self.stateHandlingDelegate?.showActivityIndicator(false)
                    self.stateHandlingDelegate?.emptyStateContol()
                    return
                }
                if followers.count < 100 {
                    self.paginationFinished?()
                }
                self.stateHandlingDelegate?.showActivityIndicator(false)
                self.delegate?.updateView(followers)
            } catch {
                stateHandlingDelegate?.showActivityIndicator(false)
                if let gfError = error as? GFError {
                    self.delegate?.error(gfError.rawValue)
                } else {
                    self.stateHandlingDelegate?.presentDefaultErrorDelegate()
                }
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
    
    public func getUserInfo() {
        stateHandlingDelegate?.showActivityIndicator(true)
        Task {
            do {
                let user = try await userService.getUserInfo(for: username)
                self.stateHandlingDelegate?.showActivityIndicator(false)
                self.delegate?.getUserInfo(user)
            } catch {
                self.stateHandlingDelegate?.showActivityIndicator(false)
                if let gfError = error as? GFError {
                    self.delegate?.error(gfError.rawValue)
                } else {
                    self.stateHandlingDelegate?.presentDefaultErrorDelegate()
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
