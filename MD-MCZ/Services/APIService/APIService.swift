//
//  APIService.swift
//  MD-MCZ
//
//  Created by Michał Czerniakowski on 24/04/2026.
//

import Foundation

enum APIError: Error, Sendable {
    case endpoint(underlying: APIEndpointError)
    case notHTTPResponse
    case httpStatus(code: Int, data: Data)
    case decoding(underlying: Error)
}

protocol APIServicing: Sendable {
    func searchRepositories(
        query: String,
        page: Int
    ) async throws -> GitHubSearchResponseDTO<GitHubRepositoryDTO>

    func searchUsers(
        query: String,
        page: Int
    ) async throws -> GitHubSearchResponseDTO<GitHubUserDTO>
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
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.count >= APIConstants.Search.minimumQueryLength else {
            return GitHubSearchResponseDTO(
                totalCount: 0,
                incompleteResults: false,
                items: []
            )
        }

        let endpoint = APIEndpoint.searchRepositories(
            query: trimmedQuery,
            perPage: APIConstants.Search.repositoriesPerPage,
            page: page
        )

        let request = makeURLRequest(for: endpoint)
        let (data, http) = try await data(for: request)
        return try decodeSuccessfulResponse(
            GitHubSearchResponseDTO<GitHubRepositoryDTO>.self,
            data: data,
            http: http
        )
    }

    func searchUsers(
        query: String,
        page: Int = 1
    ) async throws -> GitHubSearchResponseDTO<GitHubUserDTO> {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.count >= APIConstants.Search.minimumQueryLength else {
            return GitHubSearchResponseDTO(
                totalCount: 0,
                incompleteResults: false,
                items: []
            )
        }

        let endpoint = APIEndpoint.searchUsers(
            query: trimmedQuery,
            perPage: APIConstants.Search.usersPerPage,
            page: page
        )

        let request = makeURLRequest(for: endpoint)
        let (data, http) = try await data(for: request)
        return try decodeSuccessfulResponse(
            GitHubSearchResponseDTO<GitHubUserDTO>.self,
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
