//
//  SearchItem.swift
//  MD-MCZ
//
//  Created by Michael Czerniakowski on 26/04/2026.
//

import Foundation

enum SearchItem: Equatable, Sendable, Identifiable {
    case user(GitHubUserDTO)
    case repository(GitHubRepositoryDTO)

    var id: String {
        switch self {
        case .user(let user):       return "user-\(user.id)"
        case .repository(let repo): return "repo-\(repo.id)"
        }
    }

    var sortKey: String {
        switch self {
        case .user(let user):       return user.login.lowercased()
        case .repository(let repo): return repo.name.lowercased()
        }
    }
}
