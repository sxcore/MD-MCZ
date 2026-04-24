//
//  APIEndpointError.swift
//  MD-MCZ
//
//  Created by Michał Czerniakowski on 24/04/2026.
//

import Foundation

enum APIEndpointError: LocalizedError, Sendable {
    case invalidBaseURL(String)
    case invalidURL(path: String, queryItems: [URLQueryItem])

    var errorDescription: String? {
        switch self {
        case let .invalidBaseURL(base):
            return "Invalid API base URL: \(base)"
        case let .invalidURL(path, queryItems):
            return "Invalid endpoint URL for path '\(path)' with query items: \(queryItems)"
        }
    }
}
