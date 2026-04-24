//
//  APIEndpoint.swift
//  MD-MCZ
//
//  Created by Michał Czerniakowski on 24/04/2026.
//

import Foundation

enum APIEndpoint: Sendable {
    case searchRepositories(query: String, perPage: Int, page: Int)

    var method: HTTPMethod {
        switch self {
        case .searchRepositories:
            return .get
        }
    }

    func url() throws -> URL {
        var components = URLComponents()
        components.scheme = APIConstants.baseURL.scheme
        components.host = APIConstants.baseURL.host
        components.path = path
        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIEndpointError.invalidURL(path: path, queryItems: queryItems)
        }
        return url
    }

    private var path: String {
        switch self {
        case .searchRepositories:
            return APIConstants.Path.searchRepositories
        }
    }

    private var queryItems: [URLQueryItem] {
        switch self {
        case let .searchRepositories(query, perPage, page):
            return [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "per_page", value: String(perPage)),
                URLQueryItem(name: "page", value: String(page)),
            ]
        }
    }
}
