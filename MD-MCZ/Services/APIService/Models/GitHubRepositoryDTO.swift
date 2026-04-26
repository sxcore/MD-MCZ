//
//  GitHubRepositoryDTO.swift
//  MD-MCZ
//
//  Created by Michał Czerniakowski on 24/04/2026.
//

import Foundation

struct GitHubRepositoryDTO: Decodable, Sendable, Equatable, Identifiable {
    let id: Int
    let name: String
    let fullName: String
    let owner: GitHubUserDTO
    let description: String?
    let stargazersCount: Int
    let forksCount: Int
}
