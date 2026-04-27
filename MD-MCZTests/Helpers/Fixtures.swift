//
//  Fixtures.swift
//  MD-MCZTests
//
//  Created by Michał Czerniakowski on 27/04/2026.
//

import Foundation

enum Fixtures {
    static let searchRepositoriesPayload = #"""
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

    static let searchUsersPayloadSingleItem = #"""
    {
      "total_count": 1,
      "incomplete_results": false,
      "items": [
        {
          "login": "sxcore",
          "id": 13233783,
          "node_id": "MDQ6VXNlcjEzMjMzNzgz",
          "avatar_url": "https://avatars.githubusercontent.com/u/13233783?v=4",
          "gravatar_id": "",
          "url": "https://api.github.com/users/sxcore",
          "html_url": "https://github.com/sxcore",
          "type": "User",
          "site_admin": false,
          "score": 1.0
        }
      ]
    }
    """#

    static let searchUsersPayloadTwoItems = #"""
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
