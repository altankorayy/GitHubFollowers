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
    
    private var imageLoaderService: MockImageLoaderService!

    override func setUpWithError() throws {
        userService = MockUserService()
        followersListVM = FollowersListVM(userService: userService, username: testUsername)
        output = MockFollowersListViewModelOutput()
        followersListVM.delegate = output
        
        imageLoaderService = MockImageLoaderService()
    }

    override func tearDownWithError() throws {
        followersListVM = nil
        userService = nil
        imageLoaderService = nil
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
        waitForExpectations(timeout: 5)
    }
    
    func testFetchFollowers_whenAPIFailure() throws {
        userService.getFollowersMockError = GFError.invalidUsername
        
        let expectation = expectation(description: "API Call Completed")
        followersListVM.fetchFollowers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.output.errorString, GFError.invalidUsername.rawValue)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
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
        waitForExpectations(timeout: 5)
    }
    
    func testGetUserInfo_whenAPIFailure() throws {
        userService.getUserInfoMockError = GFError.invalidUsername
        
        let expectation = expectation(description: "API Call Completed")
        followersListVM.getUserInfo()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.output.errorString, GFError.invalidUsername.rawValue)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testDownloadImage_success() throws {
        let mockImageData = Data()
        imageLoaderService.downloadImageData = mockImageData
        
        let expectation = expectation(description: "Download Image Success")
        
        Task {
            do {
                let imageData = try await imageLoaderService.downloadImage("https://example.com/image.jpg")
                XCTAssertEqual(imageData, mockImageData)
            } catch {
                XCTFail("Failure: \(error)")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testDownloadImage_failure() throws {
        let mockError = GFNetworkError.unableToComplete
        imageLoaderService.downloadImageError = mockError
        
        let expectation = expectation(description: "Download Image Failure")
        
        Task {
            do {
                _ = try await imageLoaderService.downloadImage("https://example.com/image.jpg")
                XCTFail()
            } catch let error as GFNetworkError {
                XCTAssertEqual(error, mockError)
            } catch {
                XCTFail()
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testSetAPICacheResponse_whenAPICacheSuccess() throws {
        let cacheManager = CacheManager()
        let mockUrl = URL(string: "https://example.com")
        let mockData = Data()
        
        cacheManager.setAPICache(mockUrl, data: mockData)
        let cachedResponse = cacheManager.cachedAPIResponse(mockUrl)
        
        XCTAssertEqual(cachedResponse, mockData)
    }
}

class MockUserService: UserService {
    var getFollowersMockResult: [GitHubFollowers.Follower]?
    var getFollowersMockError: GFError?
    
    var getUserInfoMockResult: GitHubFollowers.User?
    var getUserInfoMockError: GFError?
    
    func getFollowers(for username: String, page: Int) async throws -> [GitHubFollowers.Follower] {
        if let result = getFollowersMockResult {
            return result
        } else if let error = getFollowersMockError {
            throw error
        } else {
            throw GFError.unableToComplete
        }
    }
    
    func getUserInfo(for username: String) async throws -> GitHubFollowers.User {
        if let result = getUserInfoMockResult {
            return result
        } else if let error = getUserInfoMockError {
            throw error
        } else {
            throw GFError.unableToComplete
        }
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

class MockImageLoaderService: ImageLoaderService {
    var downloadImageData: Data?
    var downloadImageError: GFNetworkError?
    
    func downloadImage(_ urlString: String) async throws -> Data? {
        if let data = downloadImageData {
            return data
        } else if let error = downloadImageError {
            throw error
        } else {
            throw GFNetworkError.unableToComplete
        }
    }
}
