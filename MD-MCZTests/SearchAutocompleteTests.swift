//
//  SearchAutocompleteTests.swift
//  MD-MCZTests
//
//  Created by Michael Czerniakowski on 26/04/2026.
//

import XCTest
@testable import MD_MCZ

final class SearchAutocompleteTests: XCTestCase {

    // MARK: - Spec coverage

    func test_searchAutocomplete_shortQuery_returnsEmpty_andDoesNotCallEndpoints() async throws {
        let mock = MockFactory()

        let items = try await mock.searchAutocomplete(query: "ab")

        XCTAssertTrue(items.isEmpty)
        let snapshot = await mock.snapshot()
        XCTAssertEqual(snapshot.callCount, 0)
    }

    func test_searchAutocomplete_mergesUsersAndRepos_andSortsAlphabeticallyCaseInsensitive() async throws {
        let mock = MockFactory()
        await mock.setUsersResult(.success(makeUsersResponse(logins: ["bravo", "Charlie", "alpha"])))
        await mock.setRepositoriesResult(.success(makeReposResponse(names: ["Apple", "delta", "beta"])))

        let items = try await mock.searchAutocomplete(query: "test")

        XCTAssertEqual(
            items.map(\.sortKey),
            ["alpha", "apple", "beta", "bravo", "charlie", "delta"]
        )
    }

    func test_searchAutocomplete_capsCombinedResultsAt50() async throws {
        let mock = MockFactory()
        // 30 + 30 = 60; spec says cap at 50.
        await mock.setUsersResult(.success(makeUsersResponse(logins: (0..<30).map { "user\($0)" })))
        await mock.setRepositoriesResult(.success(makeReposResponse(names: (0..<30).map { "repo\($0)" })))

        let items = try await mock.searchAutocomplete(query: "test")

        XCTAssertEqual(items.count, APIConstants.Search.combinedResultLimit)
    }

    func test_searchAutocomplete_callsBothEndpointsExactlyOnce() async throws {
        let mock = MockFactory()

        _ = try await mock.searchAutocomplete(query: "test")

        let snapshot = await mock.snapshot()
        XCTAssertEqual(snapshot.callCount, 2)
        XCTAssertEqual(snapshot.lastQuery, "test")
    }

    func test_searchAutocomplete_failureFromOneEndpointPropagates() async {
        let mock = MockFactory()
        await mock.setUsersResult(.failure(APIError.httpStatus(code: 500, data: Data())))
        await mock.setRepositoriesResult(.success(makeReposResponse(names: ["ok"])))

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
