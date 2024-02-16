//
//  GitHubFollowersTests.swift
//  GitHubFollowersTests
//
//  Created by Altan on 16.01.2024.
//

import XCTest
@testable import GitHubFollowers

final class GitHubFollowersTests: XCTestCase {
    
    private var followersListVM: FollowersListVM!
    private var userService: MockUserService!
    private var output: MockFollowersListViewModelOutput!
    private let testUsername = "testUser"

    override func setUpWithError() throws {
        userService = MockUserService()
        followersListVM = FollowersListVM(userService: userService, username: testUsername)
        output = MockFollowersListViewModelOutput()
        followersListVM.delegate = output
    }

    override func tearDownWithError() throws {
        followersListVM = nil
        userService = nil
    }

    func testFetchFollowers_whenAPISuccess() throws {
        let mockFollower = Follower(login: "testLogin", avatar_url: "testAvatarUrl.com")
        userService.getFollowersMockResult = [mockFollower]
        
        let expectation = expectation(description: "API Call Completed")
        followersListVM.fetchFollowers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.output.updateViewArray.first?.login, "testLogin")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchFollowers_whenAPIFailure() throws {
        userService.getFollowersMockError = GFError.invalidUsername
        
        let expectation = expectation(description: "API Call Completed")
        followersListVM.fetchFollowers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.output.errorString, GFError.invalidUsername.rawValue)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGetUserInfo_whenAPISuccess() throws {
        let mockUser = User(login: "testLogin", avatar_url: "testAvatarUrl.com", public_repos: 0, public_gists: 0, html_url: "", following: 0, followers: 0, created_at: "")
        userService.getUserInfoMockResult = mockUser
        
        let expectation = expectation(description: "API Call Completed")
        followersListVM.getUserInfo()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.output.updateUserInfoArray?.login, "testLogin")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGetUserInfo_whenAPIFailure() throws {
        userService.getUserInfoMockError = GFError.invalidUsername
        
        let expectation = expectation(description: "API Call Completed")
        followersListVM.getUserInfo()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.output.errorString, GFError.invalidUsername.rawValue)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}

class MockUserService: UserService {
    var getFollowersMockResult: [GitHubFollowers.Follower]?
    var getFollowersMockError: Error?
    
    var getUserInfoMockResult: GitHubFollowers.User?
    var getUserInfoMockError: Error?
    
    func getFollowers(for username: String, page: Int) async throws -> [GitHubFollowers.Follower] {
        if let result = getFollowersMockResult {
            return result
        } else if let error = getFollowersMockError {
            throw error
        }
        throw GFError.unableToComplete
    }
    
    func getUserInfo(for username: String) async throws -> GitHubFollowers.User {
        if let result = getUserInfoMockResult {
            return result
        } else if let error = getUserInfoMockError {
            throw error
        }
        throw GFError.unableToComplete
    }
}

class MockFollowersListViewModelOutput: FollowersListVMOutput {
    var updateViewArray = [GitHubFollowers.Follower]()
    var updateUserInfoArray: GitHubFollowers.User?
    var errorString: String?
    
    func updateView(_ model: [GitHubFollowers.Follower]) {
        updateViewArray = model
    }
    
    func getUserInfo(_ model: GitHubFollowers.User) {
        updateUserInfoArray = model
    }
    
    func error(_ error: String) {
        errorString = error
    }
}
