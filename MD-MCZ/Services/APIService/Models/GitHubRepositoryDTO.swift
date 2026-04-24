//
//  GitHubRepositoryDTO.swift
//  MD-MCZ
//
//  Created by Michał Czerniakowski on 24/04/2026.
//

import Foundation

struct GitHubRepositoryDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let fullName: String
    let owner: GitHubUserDTO
    let description: String?
    let stargazersCount: Int
    let forksCount: Int
    let pushedAt: String?
    let updatedAt: String?
    let htmlUrl: URL?
}
