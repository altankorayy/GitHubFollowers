//
//  APIManager.swift
//  GitHubFollowers
//
//  Created by Altan on 19.01.2024.
//

import Foundation

protocol UserService {
    func getFollowers(for username: String, page: Int, completion: @escaping(Result<[Follower], GFError>) -> Void)
}

enum GFError: String, Error {
    case invalidUsername = "This username created an invalid request. Please try again."
    case unableToComplete = "Unable to complete your request. Please check your internet connection."
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData = "The data received from the server was invalid. Please try again."
}

class NetworkManager: UserService {
    
    #warning("Cache Manager")
    
    private let baseUrl = "https://api.github.com"
    
    func getFollowers(for username: String, page: Int, completion: @escaping(Result<[Follower], GFError>) -> Void) {
        let endpoint = baseUrl + "/users/\(username)/followers?per_page=100&page=\(page)"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(GFError.invalidUsername))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(GFError.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(GFError.invalidResponse))
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let followers = try JSONDecoder().decode([Follower].self, from: data)
                    completion(.success(followers))
                } catch {
                    completion(.failure(GFError.invalidData))
                }
            }
        }
        task.resume()
    }
}
