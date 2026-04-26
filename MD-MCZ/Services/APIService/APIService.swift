//
//  APIService.swift
//  MD-MCZ
//
//  Created by Michał Czerniakowski on 24/04/2026.
//

import Foundation

enum APIError: Error, Sendable {
    case notHTTPResponse
    case httpStatus(code: Int, data: Data)
    case decoding(underlying: Error)
}

protocol APIServicing: Sendable {
    func searchRepositories(query: String, page: Int) async throws -> GitHubSearchResponseDTO<GitHubRepositoryDTO>
    func searchUsers(query: String, page: Int) async throws -> GitHubSearchResponseDTO<GitHubUserDTO>
    func searchAutocomplete(query: String) async throws -> [SearchItem]
}

actor APIService: APIServicing {

    private let session: URLSession
    private let decoder: JSONDecoder
    private let authToken: String?

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = .gitHub,
        authToken: String? = GitHubConfig.token
    ) {
        self.session = session
        self.decoder = decoder
        self.authToken = authToken?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func searchRepositories(
        query: String,
        page: Int = 1
    ) async throws -> GitHubSearchResponseDTO<GitHubRepositoryDTO> {
        try await performSearch(
            query: query,
            page: page,
            perPage: APIConstants.Search.repositoriesPerPage,
            endpoint: APIEndpoint.searchRepositories
        )
    }

    func searchUsers(
        query: String,
        page: Int = 1
    ) async throws -> GitHubSearchResponseDTO<GitHubUserDTO> {
        try await performSearch(
            query: query,
            page: page,
            perPage: APIConstants.Search.usersPerPage,
            endpoint: APIEndpoint.searchUsers
        )
    }

    private func performSearch<Item: Decodable>(
        query: String,
        page: Int,
        perPage: Int,
        endpoint: (_ query: String, _ perPage: Int, _ page: Int) -> APIEndpoint
    ) async throws -> GitHubSearchResponseDTO<Item> {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.count >= APIConstants.Search.minimumQueryLength else {
            return GitHubSearchResponseDTO(
                totalCount: 0,
                incompleteResults: false,
                items: []
            )
        }

        let request = makeURLRequest(for: endpoint(trimmedQuery, perPage, page))
        let (data, http) = try await data(for: request)
        return try decodeSuccessfulResponse(
            GitHubSearchResponseDTO<Item>.self,
            data: data,
            http: http
        )
    }

    private func makeURLRequest(for endpoint: APIEndpoint) -> URLRequest {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue(APIConstants.Header.accept, forHTTPHeaderField: "Accept")
        request.setValue(APIConstants.Header.apiVersion, forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue(APIConstants.Header.userAgent, forHTTPHeaderField: "User-Agent")
        if let authToken, authToken.isEmpty == false {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.notHTTPResponse
        }
        return (data, http)
    }

    private func decodeSuccessfulResponse<T: Decodable>(
        _ type: T.Type,
        data: Data,
        http: HTTPURLResponse
    ) throws -> T {
        guard http.isSuccessful else {
            throw APIError.httpStatus(code: http.statusCode, data: data)
        }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw APIError.decoding(underlying: error)
        }
    }
}

extension APIServicing {
    func searchAutocomplete(query: String) async throws -> [SearchItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= APIConstants.Search.minimumQueryLength else {
            return []
        }

        async let usersResponse = searchUsers(query: trimmed, page: 1)
        async let reposResponse = searchRepositories(query: trimmed, page: 1)

        let users = try await usersResponse.items.map(SearchItem.user)
        let repos = try await reposResponse.items.map(SearchItem.repository)

        let combined = (users + repos).sorted { $0.sortKey < $1.sortKey }
        return Array(combined.prefix(APIConstants.Search.combinedResultLimit))
    }
}
