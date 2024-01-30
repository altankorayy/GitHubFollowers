//
//  Model.swift
//  GitHubFollowers
//
//  Created by Altan on 19.01.2024.
//

import Foundation

struct Follower: Codable, Hashable {
    let login: String
    let avatar_url: String
}
