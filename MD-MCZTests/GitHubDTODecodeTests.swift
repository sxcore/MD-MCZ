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
        let data = Data(Self.realSearchRepositoriesPayload.utf8)
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
        let data = Data(Self.realSearchUsersPayload.utf8)
        let response = try decoder.decode(GitHubSearchResponseDTO<GitHubUserDTO>.self, from: data)
        XCTAssertEqual(response.totalCount, 2)
        XCTAssertFalse(response.incompleteResults)
        XCTAssertEqual(response.items.count, 2)
        XCTAssertEqual(response.items[0].login, "sxcore")
        XCTAssertEqual(response.items[0].id, 13_233_783)
        XCTAssertEqual(response.items[1].login, "jhomik")
        XCTAssertEqual(response.items[1].avatarUrl?.host, "avatars.githubusercontent.com")
    }

    private static let realSearchRepositoriesPayload = #"""
    {
      "total_count": 1401,
      "incomplete_results": false,
      "items": [
        {
          "id": 169972846,
          "name": "periphery",
          "full_name": "peripheryapp/periphery",
          "owner": {
            "id": 37566186,
            "login": "peripheryapp",
            "avatar_url": "https://avatars.githubusercontent.com/u/37566186?v=4"
          },
          "description": "A tool to identify unused code in Swift projects.",
          "stargazers_count": 6088,
          "forks_count": 228
        },
        {
          "id": 226959477,
          "name": "v2-periphery",
          "full_name": "Uniswap/v2-periphery",
          "owner": {
            "id": 36115574,
            "login": "Uniswap",
            "avatar_url": "https://avatars.githubusercontent.com/u/36115574?v=4"
          },
          "description": "Peripheral smart contracts for interacting with Uniswap V2",
          "stargazers_count": 1262,
          "forks_count": 1766
        },
        {
          "id": 237939035,
          "name": "VendingMachine",
          "full_name": "jhomik/VendingMachine",
          "owner": {
            "id": 29075071,
            "login": "jhomik",
            "avatar_url": "https://avatars.githubusercontent.com/u/29075071?v=4"
          },
          "description": null,
          "stargazers_count": 1,
          "forks_count": 0
        }
      ]
    }
    """#

    private static let realSearchUsersPayload = #"""
    {
      "total_count": 2,
      "incomplete_results": false,
      "items": [
        {
          "login": "sxcore",
          "id": 13233783,
          "avatar_url": "https://avatars.githubusercontent.com/u/13233783?v=4",
          "type": "User",
          "site_admin": false,
          "score": 1.0
        },
        {
          "login": "jhomik",
          "id": 29075071,
          "avatar_url": "https://avatars.githubusercontent.com/u/29075071?v=4",
          "type": "User",
          "site_admin": false,
          "score": 0.9
        }
      ]
    }
    """#
}
