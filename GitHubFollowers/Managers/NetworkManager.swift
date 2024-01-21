//
//  APIManager.swift
//  GitHubFollowers
//
//  Created by Altan on 19.01.2024.
//

import Foundation

protocol UserService {
    func getFollowers(for username: String, page: Int, completion: @escaping(Result<[Follower]?, Error>) -> Void)
}

enum NetworkManagerError: Error {
    case invalidRequest
    case networkError
    case invalidResponse
}

class NetworkManager: UserService {
    
    let baseUrl = "https://api.github.com"
    
    func getFollowers(for username: String, page: Int, completion: @escaping(Result<[Follower]?, Error>) -> Void) {
        let endpoint = baseUrl + "/users/\(username)/followers?per_page=100&page=\(page)"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkManagerError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(NetworkManagerError.networkError))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(NetworkManagerError.invalidResponse))
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let followers = try JSONDecoder().decode([Follower].self, from: data)
                    completion(.success(followers))
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
}
