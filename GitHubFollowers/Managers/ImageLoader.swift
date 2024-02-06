//
//  ImageLoader.swift
//  GitHubFollowers
//
//  Created by Altan on 22.01.2024.
//

import UIKit

protocol ImageLoaderService {
    func downloadImage(_ urlString: String, completion: @escaping(Result<Data, Error>) -> Void)
}

enum GFNetworkError: Error {
    case unableToComplete
    case invalidResponse
}

class ImageLoader: ImageLoaderService {
    
    var activeTasks: [URL: URLSessionDataTask] = [:]
    var cache = NSCache<NSString, NSData>()
    
    func downloadImage(_ urlString: String, completion: @escaping(Result<Data, Error>) -> Void) {
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completion(.success(image as Data))
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        if let existingTask = activeTasks[url] {
            existingTask.cancel()
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
            defer {
                self?.activeTasks[url] = nil
            }
            
            guard let data = data, error == nil else {
                completion(.failure(GFNetworkError.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(GFNetworkError.invalidResponse))
                return
            }
            completion(.success(data))
            self?.cache.setObject(data as NSData, forKey: cacheKey)
        }
        
        activeTasks[url] = task
        task.resume()
    }
}
