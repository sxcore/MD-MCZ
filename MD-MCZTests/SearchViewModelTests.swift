//
//  SearchViewModelTests.swift
//  MD-MCZ
//
//  Created by Michael Czerniakowski on 26/04/2026.
//

import XCTest
@testable import MD_MCZ

@MainActor
final class SearchViewModelTests: XCTestCase {

    private static let testTimingMargin = 200
    private static let pastDebounce: Duration =
        .milliseconds(APIConstants.Search.debounceMilliseconds + testTimingMargin)
    private static let beforeDebounce: Duration =
        .milliseconds(APIConstants.Search.debounceMilliseconds / 2)

    func test_shortQuery_doesNotCallAPI_andStaysIdle() async {
        let mock = MockService()
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "ab"
        try? await Task.sleep(for: Self.pastDebounce)

        XCTAssertEqual(mock.usersCallCount, 0)
        XCTAssertEqual(mock.reposCallCount, 0)
        XCTAssertEqual(viewModel.state, .idle)
    }

    func test_rapidInput_collapsesToOneAutocompleteCall_withFinalQuery() async {
        let mock = MockService()
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "te"
        viewModel.searchText = "tes"
        viewModel.searchText = "test"
        viewModel.searchText = "tests"
        try? await Task.sleep(for: Self.pastDebounce)

        XCTAssertEqual(mock.usersCallCount, 1)
        XCTAssertEqual(mock.reposCallCount, 1)
        XCTAssertEqual(mock.lastUsersQuery, "tests")
        XCTAssertEqual(mock.lastReposQuery, "tests")
    }

    func test_debounce_waitsBeforeCallingService() async {
        let mock = MockService()
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "swift"
        try? await Task.sleep(for: Self.beforeDebounce)

        XCTAssertEqual(mock.usersCallCount, 0)
        XCTAssertEqual(mock.reposCallCount, 0)
        XCTAssertEqual(viewModel.state, .idle)

        try? await Task.sleep(for: Self.pastDebounce)

        XCTAssertEqual(mock.usersCallCount, 1)
        XCTAssertEqual(mock.reposCallCount, 1)
    }

    func test_successfulNonEmptyResponse_setsResultsState() async {
        let mock = MockService()
        let repo = makeRepository(id: 1, name: "swift", login: "apple")
        let user = makeUser(id: 2, login: "adam")
        mock.reposResult = .success(makeRepoResponse(items: [repo]))
        mock.usersResult = .success(makeUserResponse(items: [user]))
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "swift"
        try? await Task.sleep(for: Self.pastDebounce)

        guard case let .results(items) = viewModel.state else {
            return XCTFail("Expected .results, got \(viewModel.state)")
        }
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items.map(\.sortKey), ["adam", "swift"])
    }

    func test_emptyResponse_setsEmptyState() async {
        let mock = MockService()
        mock.reposResult = .success(makeRepoResponse(items: []))
        mock.usersResult = .success(makeUserResponse(items: []))
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "rare-query"
        try? await Task.sleep(for: Self.pastDebounce)

        XCTAssertEqual(viewModel.state, .empty)
    }

    func test_serviceError_setsErrorStateWithNonEmptyMessage() async {
        let mock = MockService()
        mock.usersResult = .failure(APIError.httpStatus(code: 403, data: Data()))
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "anything"
        try? await Task.sleep(for: Self.pastDebounce)

        guard case let .error(message) = viewModel.state else {
            return XCTFail("Expected .error, got \(viewModel.state)")
        }
        XCTAssertFalse(message.isEmpty)
    }

    func test_supersededByShortQuery_doesNotEnterErrorState() async {
        let mock = MockService()
        mock.reposResult = .failure(APIError.httpStatus(code: 500, data: Data()))
        mock.usersResult = .failure(APIError.httpStatus(code: 500, data: Data()))
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "first"
        viewModel.searchText = "ab"
        try? await Task.sleep(for: Self.pastDebounce)

        XCTAssertEqual(mock.usersCallCount, 0)
        XCTAssertEqual(mock.reposCallCount, 0)
        XCTAssertEqual(viewModel.state, .idle)
    }

    func test_staleRequestDoesNotOverrideLatestResults() async {
        let service = DelayedAutocompleteService()
        let firstItem = makeSearchRepository(id: 1, name: "first")
        let secondItem = makeSearchRepository(id: 2, name: "second")
        await service.setResponse(query: "first", delay: .milliseconds(1_000), items: [firstItem])
        await service.setResponse(query: "second", delay: .zero, items: [secondItem])
        let viewModel = SearchViewModel(service: service)

        viewModel.searchText = "first"
        try? await Task.sleep(for: Self.pastDebounce)
        viewModel.searchText = "second"
        try? await Task.sleep(for: Self.pastDebounce)

        guard case let .results(items) = viewModel.state else {
            return XCTFail("Expected .results, got \(viewModel.state)")
        }
        XCTAssertEqual(items.map(\.sortKey), ["second"])
    }

    // MARK: - Builders

    private func makeRepoResponse(
        items: [GitHubRepositoryDTO]
    ) -> GitHubSearchResponseDTO<GitHubRepositoryDTO> {
        GitHubSearchResponseDTO(
            totalCount: items.count,
            incompleteResults: false,
            items: items
        )
    }

    private func makeUserResponse(
        items: [GitHubUserDTO]
    ) -> GitHubSearchResponseDTO<GitHubUserDTO> {
        GitHubSearchResponseDTO(
            totalCount: items.count,
            incompleteResults: false,
            items: items
        )
    }

    private func makeUser(id: Int, login: String) -> GitHubUserDTO {
        GitHubUserDTO(
            id: id,
            login: login,
            avatarUrl: nil
        )
    }

    private func makeRepository(id: Int, name: String, login: String) -> GitHubRepositoryDTO {
        GitHubRepositoryDTO(
            id: id,
            name: name,
            fullName: "\(login)/\(name)",
            owner: GitHubUserDTO(id: id, login: login, avatarUrl: nil),
            description: nil,
            stargazersCount: 0,
            forksCount: 0
        )
    }

    private func makeSearchRepository(id: Int, name: String) -> SearchItem {
        .repository(
            GitHubRepositoryDTO(
                id: id,
                name: name,
                fullName: "owner/\(name)",
                owner: GitHubUserDTO(id: id, login: "owner", avatarUrl: nil),
                description: nil,
                stargazersCount: 0,
                forksCount: 0
            )
        )
    }
}

private actor DelayedAutocompleteService: APIServicing {
    struct Plan {
        let delay: Duration
        let items: [SearchItem]
    }

    private var plans: [String: Plan] = [:]

    func setResponse(query: String, delay: Duration, items: [SearchItem]) {
        plans[query] = Plan(delay: delay, items: items)
    }

    func searchAutocomplete(query: String) async throws -> [SearchItem] {
        let plan = plans[query] ?? Plan(delay: .zero, items: [])
        try await Task.sleep(for: plan.delay)
        return plan.items
    }

    func searchRepositories(query: String, page: Int) async throws -> GitHubSearchResponseDTO<GitHubRepositoryDTO> {
        GitHubSearchResponseDTO(totalCount: 0, incompleteResults: false, items: [])
    }

    func searchUsers(query: String, page: Int) async throws -> GitHubSearchResponseDTO<GitHubUserDTO> {
        GitHubSearchResponseDTO(totalCount: 0, incompleteResults: false, items: [])
    }
}
