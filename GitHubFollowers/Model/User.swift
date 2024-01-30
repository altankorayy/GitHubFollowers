//
//  User.swift
//  GitHubFollowers
//
//  Created by Altan on 19.01.2024.
//

import Foundation

struct User: Codable {
    let login: String
    let avatar_url: String
    var name: String?
    var location: String?
    var bio: String?
    let public_repos: Int
    let public_gists: Int
    let html_url: String
    let following: Int
    let followers: Int
    let created_at: String
}
