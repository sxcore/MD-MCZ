//
//  MockService.swift
//  MD-MCZTests
//
//  Created by Michael Czerniakowski on 26/04/2026.
//

import Foundation
@testable import MD_MCZ

final class MockFactory: APIServicing, @unchecked Sendable {
    private(set) var callCount = 0
    private(set) var lastQuery: String?

    var result: Result<GitHubSearchResponseDTO<GitHubRepositoryDTO>, Error> =
        .success(GitHubSearchResponseDTO(totalCount: 0, incompleteResults: false, items: []))
    var usersResult: Result<GitHubSearchResponseDTO<GitHubUserDTO>, Error> =
        .success(GitHubSearchResponseDTO(totalCount: 0, incompleteResults: false, items: []))

    func searchRepositories(
        query: String,
        page: Int
    ) async throws -> GitHubSearchResponseDTO<GitHubRepositoryDTO> {
        callCount += 1
        lastQuery = query
        return try result.get()
    }

    func searchUsers(
        query: String,
        page: Int
    ) async throws -> GitHubSearchResponseDTO<GitHubUserDTO> {
        callCount += 1
        lastQuery = query
        return try usersResult.get()
    }
}
