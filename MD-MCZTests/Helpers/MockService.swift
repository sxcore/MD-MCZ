//
//  MockService.swift
//  MD-MCZTests
//
//  Created by Michael Czerniakowski on 26/04/2026.
//

import Foundation
@testable import MD_MCZ

final class MockService: APIServicing, @unchecked Sendable {

    var usersResult: Result<GitHubSearchResponseDTO<GitHubUserDTO>, Error> =
        .success(GitHubSearchResponseDTO(totalCount: 0, incompleteResults: false, items: []))
    var reposResult: Result<GitHubSearchResponseDTO<GitHubRepositoryDTO>, Error> =
        .success(GitHubSearchResponseDTO(totalCount: 0, incompleteResults: false, items: []))

    private(set) var usersCallCount = 0
    private(set) var reposCallCount = 0
    private(set) var lastUsersQuery: String?
    private(set) var lastReposQuery: String?

    func searchUsers(
        query: String,
        page: Int
    ) async throws -> GitHubSearchResponseDTO<GitHubUserDTO> {
        usersCallCount += 1
        lastUsersQuery = query
        return try usersResult.get()
    }

    func searchRepositories(
        query: String,
        page: Int
    ) async throws -> GitHubSearchResponseDTO<GitHubRepositoryDTO> {
        reposCallCount += 1
        lastReposQuery = query
        return try reposResult.get()
    }
}
