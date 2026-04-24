//
//  GitHubSearchRepositoriesResponseDTO.swift
//  MD-MCZ
//
//  Created by Michał Czerniakowski on 24/04/2026.
//

import Foundation

struct GitHubSearchRepositoriesResponseDTO: Decodable, Sendable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [GitHubRepositoryDTO]
}
