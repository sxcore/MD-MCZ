//
//  APIServiceTests.swift
//  MD-MCZTests
//
//  Created by Michał Czerniakowski on 24/04/2026.
//

import Foundation
import XCTest
@testable import MD_MCZ

final class APIServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        MockURLProtocol.requestHandler = nil
    }

    func testSearchRepositoriesDoesNotCallAPIForShortQuery() async throws {
        let apiService = APIService(session: makeMockedSession(), decoder: .gitHub, authToken: "token")

        var requestCount = 0
        MockURLProtocol.requestHandler = { request in
            requestCount += 1
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let response = try await apiService.searchRepositories(query: "ab", page: 1)
        XCTAssertEqual(response.totalCount, 0)
        XCTAssertTrue(response.items.isEmpty)
        XCTAssertEqual(requestCount, 0)
    }

    func testSearchRepositoriesSendsHeadersAndDecodesResponse() async throws {
        let apiService = APIService(session: makeMockedSession(), decoder: .gitHub, authToken: "abc123")

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer abc123")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/vnd.github+json")
            XCTAssertEqual(request.value(forHTTPHeaderField: "X-GitHub-Api-Version"), "2022-11-28")

            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(Fixtures.searchRepositoriesPayload.utf8))
        }

        let result = try await apiService.searchRepositories(query: "periphery", page: 2)
        XCTAssertEqual(result.totalCount, 1_401)
        XCTAssertFalse(result.incompleteResults)
        XCTAssertEqual(result.items.count, 3)
        XCTAssertEqual(result.items[0].id, 169_972_846)
        XCTAssertEqual(result.items[0].fullName, "peripheryapp/periphery")
    }

    func testSearchRepositoriesDoesNotSendAuthorizationHeaderWhenTokenMissing() async throws {
        let apiService = APIService(session: makeMockedSession(), decoder: .gitHub, authToken: nil)

        MockURLProtocol.requestHandler = { request in
            XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(Fixtures.searchRepositoriesPayload.utf8))
        }

        _ = try await apiService.searchRepositories(query: "swift", page: 1)
    }

    func testSearchRepositoriesThrowsHTTPStatusForNonSuccess() async {
        let apiService = APIService(session: makeMockedSession(), decoder: .gitHub, authToken: nil)
        let responseBody = #"{"message":"forbidden"}"#

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 403, httpVersion: nil, headerFields: nil)!
            return (response, Data(responseBody.utf8))
        }

        do {
            _ = try await apiService.searchRepositories(query: "swift", page: 1)
            XCTFail("Expected APIError.httpStatus")
        } catch APIError.httpStatus(let code, let data) {
            XCTAssertEqual(code, 403)
            XCTAssertEqual(String(data: data, encoding: .utf8), responseBody)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testSearchRepositoriesThrowsDecodingErrorForMalformedPayload() async {
        let apiService = APIService(session: makeMockedSession(), decoder: .gitHub, authToken: nil)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let badJSON = #"{"total_count":"not_an_int","incomplete_results":false,"items":[]}"#
            return (response, Data(badJSON.utf8))
        }

        do {
            _ = try await apiService.searchRepositories(query: "swift", page: 1)
            XCTFail("Expected APIError.decoding")
        } catch APIError.decoding {
            // Expected.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testSearchUsersDecodesResponse() async throws {
        let apiService = APIService(session: makeMockedSession(), decoder: .gitHub, authToken: "abc123")

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(Fixtures.searchUsersPayloadSingleItem.utf8))
        }

        let result = try await apiService.searchUsers(query: "sxcore", page: 1)
        XCTAssertFalse(result.incompleteResults)
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items[0].id, 13_233_783)
        XCTAssertEqual(result.items[0].login, "sxcore")
        XCTAssertEqual(result.items[0].avatarUrl?.host, "avatars.githubusercontent.com")
    }

    private func makeMockedSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}

private final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
