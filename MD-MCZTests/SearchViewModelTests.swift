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

    private static let pastDebounce: Duration = .milliseconds(APIConstants.Search.debounceMilliseconds + 200)

    func test_shortQuery_doesNotCallAPI_andStaysIdle() async {
        let mock = MockService()
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "ab"
        try? await Task.sleep(for: Self.pastDebounce)

        XCTAssertEqual(mock.callCount, 0)
        XCTAssertEqual(viewModel.state, .idle)
    }

    func test_rapidInput_collapsesToOneCall_withFinalQuery() async {
        let mock = MockService()
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "te"
        viewModel.searchText = "tes"
        viewModel.searchText = "test"
        viewModel.searchText = "tests"
        try? await Task.sleep(for: Self.pastDebounce)

        XCTAssertEqual(mock.callCount, 1)
        XCTAssertEqual(mock.lastQuery, "tests")
    }

    func test_successfulNonEmptyResponse_setsResultsState() async {
        let mock = MockService()
        let item = makeRepository(id: 1, name: "swift", login: "apple")
        mock.result = .success(makeResponse(items: [item]))
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "swift"
        try? await Task.sleep(for: Self.pastDebounce)

        guard case let .results(items) = viewModel.state else {
            return XCTFail("Expected .results, got \(viewModel.state)")
        }
        XCTAssertEqual(items.map(\.id), [1])
    }

    func test_emptyResponse_setsEmptyState() async {
        let mock = MockService()
        mock.result = .success(makeResponse(items: []))
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "rare-query"
        try? await Task.sleep(for: Self.pastDebounce)

        XCTAssertEqual(viewModel.state, .empty)
    }

    func test_serviceError_setsErrorStateWithNonEmptyMessage() async {
        let mock = MockService()
        mock.result = .failure(APIError.httpStatus(code: 403, data: Data()))
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
        mock.result = .failure(APIError.httpStatus(code: 500, data: Data()))
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "first"
        viewModel.searchText = "ab"
        try? await Task.sleep(for: Self.pastDebounce)

        XCTAssertEqual(mock.callCount, 0)
        XCTAssertEqual(viewModel.state, .idle)
    }

    // MARK: - Builders

    private func makeResponse(
        items: [GitHubRepositoryDTO]
    ) -> GitHubSearchResponseDTO<GitHubRepositoryDTO> {
        GitHubSearchResponseDTO(
            totalCount: items.count,
            incompleteResults: false,
            items: items
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
}

// MARK: - Mock

private final class MockService: APIServicing, @unchecked Sendable {
    private(set) var callCount = 0
    private(set) var lastQuery: String?
    var result: Result<GitHubSearchResponseDTO<GitHubRepositoryDTO>, Error> =
        .success(GitHubSearchResponseDTO(totalCount: 0, incompleteResults: false, items: []))

    func searchRepositories(
        query: String,
        page: Int
    ) async throws -> GitHubSearchResponseDTO<GitHubRepositoryDTO> {
        callCount += 1
        lastQuery = query
        return try result.get()
    }
}

