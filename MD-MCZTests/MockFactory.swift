//
//  MockFactory.swift
//  MD-MCZTests
//
//  Created by Michael Czerniakowski on 26/04/2026.
//

import Foundation
@testable import MD_MCZ

actor MockFactory: APIServicing {
    struct Snapshot: Sendable {
        let callCount: Int
        let lastQuery: String?
    }

    private var callCount = 0
    private var lastQuery: String?

    private var result: Result<GitHubSearchResponseDTO<GitHubRepositoryDTO>, Error> =
        .success(GitHubSearchResponseDTO(totalCount: 0, incompleteResults: false, items: []))
    private var usersResult: Result<GitHubSearchResponseDTO<GitHubUserDTO>, Error> =
        .success(GitHubSearchResponseDTO(totalCount: 0, incompleteResults: false, items: []))

    func setRepositoriesResult(_ newValue: Result<GitHubSearchResponseDTO<GitHubRepositoryDTO>, Error>) {
        result = newValue
    }

    func setUsersResult(_ newValue: Result<GitHubSearchResponseDTO<GitHubUserDTO>, Error>) {
        usersResult = newValue
    }

    func snapshot() -> Snapshot {
        Snapshot(callCount: callCount, lastQuery: lastQuery)
    }

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
