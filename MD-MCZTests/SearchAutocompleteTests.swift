//
//  SearchAutocompleteTests.swift
//  MD-MCZTests
//
//  Created by Michael Czerniakowski on 26/04/2026.
//

import XCTest
@testable import MD_MCZ

final class SearchAutocompleteTests: XCTestCase {

    func test_searchAutocomplete_shortQuery_returnsEmpty_andDoesNotCallEndpoints() async throws {
        let mock = MockService()

        let items = try await mock.searchAutocomplete(query: "ab")

        XCTAssertTrue(items.isEmpty)
        XCTAssertEqual(mock.usersCallCount, 0)
        XCTAssertEqual(mock.reposCallCount, 0)
    }

    func test_searchAutocomplete_mergesUsersAndRepos_andSortsAlphabeticallyCaseInsensitive() async throws {
        let mock = MockService()
        mock.usersResult = .success(makeUsersResponse(logins: ["bravo", "Charlie", "alpha"]))
        mock.reposResult = .success(makeReposResponse(names: ["Apple", "delta", "beta"]))

        let items = try await mock.searchAutocomplete(query: "test")

        XCTAssertEqual(
            items.map(\.sortKey),
            ["alpha", "apple", "beta", "bravo", "charlie", "delta"]
        )
    }

    func test_searchAutocomplete_capsCombinedResultsAt50() async throws {
        let mock = MockService()
        mock.usersResult = .success(makeUsersResponse(logins: (0..<30).map { "user\($0)" }))
        mock.reposResult = .success(makeReposResponse(names: (0..<30).map { "repo\($0)" }))

        let items = try await mock.searchAutocomplete(query: "test")

        XCTAssertEqual(items.count, APIConstants.Search.combinedResultLimit)
    }

    func test_searchAutocomplete_callsBothEndpointsExactlyOnce() async throws {
        let mock = MockService()

        _ = try await mock.searchAutocomplete(query: "test")

        XCTAssertEqual(mock.usersCallCount, 1)
        XCTAssertEqual(mock.reposCallCount, 1)
        XCTAssertEqual(mock.lastUsersQuery, "test")
        XCTAssertEqual(mock.lastReposQuery, "test")
    }

    func test_searchAutocomplete_failureFromOneEndpointPropagates() async {
        let mock = MockService()
        mock.usersResult = .failure(APIError.httpStatus(code: 500, data: Data()))
        mock.reposResult = .success(makeReposResponse(names: ["ok"]))

        do {
            _ = try await mock.searchAutocomplete(query: "test")
            XCTFail("Expected APIError.httpStatus")
        } catch APIError.httpStatus(let code, _) {
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Builders

    private func makeUsersResponse(
        logins: [String]
    ) -> GitHubSearchResponseDTO<GitHubUserDTO> {
        let items = logins.enumerated().map { index, login in
            GitHubUserDTO(id: index, login: login, avatarUrl: nil)
        }
        return GitHubSearchResponseDTO(
            totalCount: items.count,
            incompleteResults: false,
            items: items
        )
    }

    private func makeReposResponse(
        names: [String]
    ) -> GitHubSearchResponseDTO<GitHubRepositoryDTO> {
        let items = names.enumerated().map { index, name in
            GitHubRepositoryDTO(
                id: index,
                name: name,
                fullName: "owner/\(name)",
                owner: GitHubUserDTO(id: index, login: "owner", avatarUrl: nil),
                description: nil,
                stargazersCount: 0,
                forksCount: 0
            )
        }
        return GitHubSearchResponseDTO(
            totalCount: items.count,
            incompleteResults: false,
            items: items
        )
    }
}
