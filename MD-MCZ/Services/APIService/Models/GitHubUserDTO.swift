//
//  GitHubUserDTO.swift
//  MD-MCZ
//
//  Created by Michał Czerniakowski on 24/04/2026.
//

import Foundation

struct GitHubUserDTO: Decodable, Sendable, Equatable {
    let id: Int
    let login: String
    let avatarUrl: URL?
}
