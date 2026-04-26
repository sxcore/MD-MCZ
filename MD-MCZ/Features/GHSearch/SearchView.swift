//
//  SearchView.swift
//  MD-MCZ
//
//  Created by Michael Czerniakowski on 26/04/2026.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel

    init(service: APIServicing = APIService()) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(service: service))
    }

    var body: some View {
        NavigationStack {
            content
                .searchable(text: $viewModel.searchText, prompt: "Search GitHub repositories")
                .navigationTitle("Search")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            ContentUnavailableView(
                "Type to search",
                systemImage: "magnifyingglass",
                description: Text("Enter at least \(APIConstants.Search.minimumQueryLength) characters.")
            )
        case .loading:
            ProgressView()
        case .empty:
            ContentUnavailableView.search
        case .results(let repos):
            List(repos) { repo in
                RepositoryRow(repo: repo)
            }
        case .error(let message):
            ContentUnavailableView(
                "Something went wrong",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
        }
    }
}

private struct RepositoryRow: View {
    let repo: GitHubRepositoryDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(repo.name)
                .font(.headline)
            Text(repo.fullName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let description = repo.description, description.isEmpty == false {
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }
}

#if DEBUG
private struct PreviewService: APIServicing {
    let canned: [GitHubRepositoryDTO]

    func searchRepositories(
        query: String,
        page: Int
    ) async throws -> GitHubSearchResponseDTO<GitHubRepositoryDTO> {
        GitHubSearchResponseDTO(
            totalCount: canned.count,
            incompleteResults: false,
            items: canned
        )
    }

    func searchUsers(
        query: String,
        page: Int
    ) async throws -> GitHubSearchResponseDTO<GitHubUserDTO> {
        GitHubSearchResponseDTO(totalCount: 0, incompleteResults: false, items: [])
    }
}

#Preview("Empty / typing") {
    SearchView(service: PreviewService(canned: []))
}

#Preview("Results") {
    let repo = GitHubRepositoryDTO(
        id: 1,
        name: "MD-MC",
        fullName: "sxcore/MD-MC",
        owner: GitHubUserDTO(id: 1, login: "sxcore", avatarUrl: nil),
        description: "TEST REPO",
        stargazersCount: 1,
        forksCount: 0
    )
    SearchView(service: PreviewService(canned: [repo]))
}
#endif
