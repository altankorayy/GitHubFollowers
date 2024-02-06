//
//  CacheManager.swift
//  GitHubFollowers
//
//  Created by Altan on 6.02.2024.
//

import Foundation

class CacheManager {
    
    var apiDataCache = NSCache<NSString, NSData>()
    
    public func setAPICache(_ url: URL?, data: Data) {
        guard let key = url?.absoluteString as? NSString else { return }
        let nsData = data as NSData
        
        apiDataCache.setObject(nsData, forKey: key)
    }
    
    public func cachedAPIResponse(_ url: URL?) -> Data? {
        guard let key = url?.absoluteString as? NSString else { return nil }
        guard let targetCache = apiDataCache.object(forKey: key) else { return nil }
        
        return targetCache as Data
    }
}
