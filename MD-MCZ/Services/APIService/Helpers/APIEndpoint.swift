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

    var url: URL {
        APIConstants.baseURL
            .appending(path: path)
            .appending(queryItems: queryItems)
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
