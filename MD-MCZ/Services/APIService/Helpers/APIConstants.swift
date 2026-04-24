//
//  APIConstants.swift
//  MD-MCZ
//
//  Created by Michał Czerniakowski on 24/04/2026.
//

import Foundation

enum APIConstants {
    enum Header {
        static let accept = "application/vnd.github+json"
        static let apiVersion = "2022-11-28"
        static let userAgent = "MD-MCZ/1.0"
    }

    enum Search {
        static let minimumQueryLength = 3
        static let usersPerPage = 50
        static let repositoriesPerPage = 50
    }
}
