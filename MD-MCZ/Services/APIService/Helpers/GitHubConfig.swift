//
//  GitHubConfig.swift
//  MD-MCZ
//
//  Created by Michał Czerniakowski on 25/04/2026.
//

import Foundation

enum GitHubConfig {
    static let token: String? = {
        if let raw = Bundle.main.object(forInfoDictionaryKey: "GITHUB_TOKEN") as? String, let t = sanitized(raw) {
            return t
        }
        if let env = ProcessInfo.processInfo.environment["GITHUB_TOKEN"], let t = sanitized(env) {
            return t
        }
        #if DEBUG
        print("Missing GITHUB_TOKEN (Info.plist/env)")
        #endif
        return nil
    }()

    private static func sanitized(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return nil }
        guard trimmed.contains("$(") == false else { return nil }
        return trimmed
    }
}
