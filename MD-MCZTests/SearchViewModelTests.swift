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
        let mock = MockFactory()
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "ab"
        try? await Task.sleep(for: Self.pastDebounce)

        let snapshot = await mock.snapshot()
        XCTAssertEqual(snapshot.callCount, 0)
        XCTAssertEqual(viewModel.state, .idle)
    }

    func test_rapidInput_collapsesToOneCall_withFinalQuery() async {
        let mock = MockFactory()
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "te"
        viewModel.searchText = "tes"
        viewModel.searchText = "test"
        viewModel.searchText = "tests"
        try? await Task.sleep(for: Self.pastDebounce)

        let snapshot = await mock.snapshot()
        XCTAssertEqual(snapshot.callCount, 2)
        XCTAssertEqual(snapshot.lastQuery, "tests")
    }

    func test_successfulNonEmptyResponse_setsResultsState() async {
        let mock = MockFactory()
        let repo = makeRepository(id: 1, name: "swift", login: "apple")
        let user = makeUser(id: 2, login: "adam")
        await mock.setRepositoriesResult(.success(makeRepoResponse(items: [repo])))
        await mock.setUsersResult(.success(makeUserResponse(items: [user])))
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
        let mock = MockFactory()
        await mock.setRepositoriesResult(.success(makeRepoResponse(items: [])))
        await mock.setUsersResult(.success(makeUserResponse(items: [])))
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "rare-query"
        try? await Task.sleep(for: Self.pastDebounce)

        XCTAssertEqual(viewModel.state, .empty)
    }

    func test_serviceError_setsErrorStateWithNonEmptyMessage() async {
        let mock = MockFactory()
        await mock.setUsersResult(.failure(APIError.httpStatus(code: 403, data: Data())))
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "anything"
        try? await Task.sleep(for: Self.pastDebounce)

        guard case let .error(message) = viewModel.state else {
            return XCTFail("Expected .error, got \(viewModel.state)")
        }
        XCTAssertFalse(message.isEmpty)
    }

    func test_supersededByShortQuery_doesNotEnterErrorState() async {
        let mock = MockFactory()
        await mock.setRepositoriesResult(.failure(APIError.httpStatus(code: 500, data: Data())))
        await mock.setUsersResult(.failure(APIError.httpStatus(code: 500, data: Data())))
        let viewModel = SearchViewModel(service: mock)

        viewModel.searchText = "first"
        viewModel.searchText = "ab"
        try? await Task.sleep(for: Self.pastDebounce)

        let snapshot = await mock.snapshot()
        XCTAssertEqual(snapshot.callCount, 0)
        XCTAssertEqual(viewModel.state, .idle)
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
}
