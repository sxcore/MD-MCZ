//
//  APIEndpointTests.swift
//  MD-MCZTests
//
//  Created by Michael Czerniakowski on 26/04/2026.
//

import XCTest
@testable import MD_MCZ

final class APIEndpointTests: XCTestCase {

    func testSearchRepositoriesEndpointBuildsExpectedURL() {
        let endpoint = APIEndpoint.searchRepositories(query: "swift", perPage: 50, page: 2)
        let components = URLComponents(url: endpoint.url, resolvingAgainstBaseURL: false)

        XCTAssertEqual(endpoint.method, .get)
        XCTAssertEqual(components?.scheme, "https")
        XCTAssertEqual(components?.host, "api.github.com")
        XCTAssertEqual(components?.path, "/search/repositories")
        XCTAssertEqual(components?.queryItems?.first { $0.name == "q" }?.value, "swift")
        XCTAssertEqual(components?.queryItems?.first { $0.name == "per_page" }?.value, "50")
        XCTAssertEqual(components?.queryItems?.first { $0.name == "page" }?.value, "2")
    }

    func testSearchUsersEndpointBuildsExpectedURL() {
        let endpoint = APIEndpoint.searchUsers(query: "john", perPage: 50, page: 1)
        let components = URLComponents(url: endpoint.url, resolvingAgainstBaseURL: false)

        XCTAssertEqual(endpoint.method, .get)
        XCTAssertEqual(components?.scheme, "https")
        XCTAssertEqual(components?.host, "api.github.com")
        XCTAssertEqual(components?.path, "/search/users")
        XCTAssertEqual(components?.queryItems?.first { $0.name == "q" }?.value, "john")
        XCTAssertEqual(components?.queryItems?.first { $0.name == "per_page" }?.value, "50")
        XCTAssertEqual(components?.queryItems?.first { $0.name == "page" }?.value, "1")
    }

    func testSearchEndpointPercentEncodesQuery() {
        let rawQuery = "swift ui + actor"
        let endpoint = APIEndpoint.searchRepositories(query: rawQuery, perPage: 10, page: 1)
        let components = URLComponents(url: endpoint.url, resolvingAgainstBaseURL: false)

        XCTAssertEqual(components?.queryItems?.first { $0.name == "q" }?.value, rawQuery)
        XCTAssertTrue(endpoint.url.absoluteString.contains("q=swift%20ui%20+%20actor"))
    }
}
