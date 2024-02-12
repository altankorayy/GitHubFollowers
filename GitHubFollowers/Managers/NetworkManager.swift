//
//  APIManager.swift
//  GitHubFollowers
//
//  Created by Altan on 19.01.2024.
//

import Foundation

protocol UserService {
    func getFollowers(for username: String, page: Int) async throws -> [Follower]
//  func getFollowers(for username: String, page: Int, completion: @escaping(Result<[Follower], GFError>) -> Void)
    
    func getUserInfo(for username: String) async throws -> User
//  func getUserInfo(for username: String, completion: @escaping(Result<User, GFError>) -> Void)
}

enum GFError: String, Error {
    case invalidUsername = "This username created an invalid request. Please try again."
    case unableToComplete = "Unable to complete your request. Please check your internet connection."
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData = "The data received from the server was invalid. Please try again."
    case unableToFavorite = "There was an error favoriting this user. Please try again."
    case alreadyInFavorites = "You've already favorited this user. You must REALLY like them!"
    case cachedResponseError = "Failed to get cached response."
}

class NetworkManager: UserService {
    
    let cacheManager = CacheManager()
    
    private let baseUrl = "https://api.github.com"
    
    func getFollowers(for username: String, page: Int) async throws -> [Follower] {
        let endpoint = baseUrl + "/users/\(username)/followers?per_page=100&page=\(page)"
        
        guard let url = URL(string: endpoint) else {
            throw GFError.invalidUsername
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let cachedData = cacheManager.cachedAPIResponse(url) {
            do {
                return try JSONDecoder().decode([Follower].self, from: cachedData)
            } catch {
                throw GFError.cachedResponseError
            }
        }
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GFError.invalidResponse
        }
        
        do {
            self.cacheManager.setAPICache(url, data: data)
            return try JSONDecoder().decode([Follower].self, from: data)
        } catch {
            throw GFError.invalidData
        }
    }
    
    //MARK: - iOS < 15.0
    //     func getFollowers(for username: String, page: Int, completion: @escaping(Result<[Follower], GFError>) -> Void) {
    //         let endpoint = baseUrl + "/users/\(username)/followers?per_page=100&page=\(page)"
    //
    //         guard let url = URL(string: endpoint) else {
    //             completion(.failure(GFError.invalidUsername))
    //             return
    //         }
    //
    //         if let cachedData = cacheManager.cachedAPIResponse(url) {
    //             do {
    //                 let result = try JSONDecoder().decode([Follower].self, from: cachedData)
    //                 completion(.success(result))
    //             } catch {
    //                 completion(.failure(GFError.cachedResponseError))
    //             }
    //         }
    //
    //         let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
    //             guard let data = data, error == nil else {
    //                 completion(.failure(GFError.unableToComplete))
    //                 return
    //             }
    //
    //             guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
    //                 completion(.failure(GFError.invalidResponse))
    //                 return
    //             }
    //
    //             DispatchQueue.main.async {
    //                 do {
    //                     let followers = try JSONDecoder().decode([Follower].self, from: data)
    //                     self?.cacheManager.setAPICache(url, data: data)
    //                     completion(.success(followers))
    //                 } catch {
    //                     completion(.failure(GFError.invalidData))
    //                 }
    //             }
    //         }
    //         task.resume()
    //     }
    
    func getUserInfo(for username: String) async throws -> User {
        let endPoint = baseUrl + "/users/\(username)"
        
        guard let url = URL(string: endPoint) else {
            throw GFError.invalidUsername
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GFError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(User.self, from: data)
        } catch {
            throw GFError.invalidData
        }
    }
}
    
//MARK: - iOS < 15.0
//    func getUserInfo(for username: String, completion: @escaping(Result<User, GFError>) -> Void) {
//        let endPoint = baseUrl + "/users/\(username)"
//
//        guard let url = URL(string: endPoint) else {
//            completion(.failure(GFError.invalidUsername))
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
//            guard let data = data, error == nil else {
//                completion(.failure(GFError.unableToComplete))
//                return
//            }
//
//            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//                completion(.failure(GFError.invalidResponse))
//                return
//            }
//
//            do {
//                let user = try JSONDecoder().decode(User.self, from: data)
//                completion(.success(user))
//            } catch {
//                completion(.failure(GFError.invalidData))
//            }
//        }
//        task.resume()
//    }
//}
