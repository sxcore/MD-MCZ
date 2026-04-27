//
//  GitHubDTODecodeTests.swift
//  MD_MCZTests
//
//  Created by Michał Czerniakowski on 24/04/2026.
//

import XCTest
@testable import MD_MCZ

final class GitHubDTODecodeTests: XCTestCase {

    private let decoder = JSONDecoder.gitHub

    func testDecodeGitHubSearchRepositoriesResponseDTO_fromRealSearchResponse() throws {
        let data = Data(Fixtures.searchRepositoriesPayload.utf8)
        let response = try decoder.decode(GitHubSearchResponseDTO<GitHubRepositoryDTO>.self, from: data)
        XCTAssertEqual(response.totalCount, 1_401)
        XCTAssertFalse(response.incompleteResults)
        XCTAssertEqual(response.items.count, 3)
        XCTAssertEqual(response.items[0].id, 169_972_846)
        XCTAssertEqual(response.items[0].fullName, "peripheryapp/periphery")
        XCTAssertEqual(response.items[0].owner.login, "peripheryapp")
        XCTAssertNil(response.items[2].description)
    }

    func testDecodeGitHubSearchUsersResponseDTO_fromRealSearchResponse() throws {
        let data = Data(Fixtures.searchUsersPayloadTwoItems.utf8)
        let response = try decoder.decode(GitHubSearchResponseDTO<GitHubUserDTO>.self, from: data)
        XCTAssertEqual(response.totalCount, 2)
        XCTAssertFalse(response.incompleteResults)
        XCTAssertEqual(response.items.count, 2)
        XCTAssertEqual(response.items[0].login, "sxcore")
        XCTAssertEqual(response.items[0].id, 13_233_783)
        XCTAssertEqual(response.items[1].login, "jhomik")
        XCTAssertEqual(response.items[1].avatarUrl?.host, "avatars.githubusercontent.com")
    }

}
