//
//  GitHubConfig.swift
//  MD-MCZ
//
//  Created by Michał Czerniakowski on 25/04/2026.
//

import Foundation

enum GitHubConfig {
    static let diagnostics: String = {
        let rawInfo = Bundle.main.object(forInfoDictionaryKey: "GITHUB_TOKEN") as? String
        let rawEnv = ProcessInfo.processInfo.environment["GITHUB_TOKEN"]
        let infoSummary = summarize(rawInfo)
        let envSummary = summarize(rawEnv)
        return "GitHub token sources -> Info.plist: \(infoSummary), env: \(envSummary)"
    }()

    static let token: String? = {
        if let raw = Bundle.main.object(forInfoDictionaryKey: "GITHUB_TOKEN") as? String, let t = sanitized(raw) {
            #if DEBUG
            print("GITHUB_TOKEN from Info.plist (\(t.count) chars)")
            #endif
            return t
        }
        if let env = ProcessInfo.processInfo.environment["GITHUB_TOKEN"], let t = sanitized(env) {
            #if DEBUG
            print("GITHUB_TOKEN from scheme environment (\(t.count) chars)")
            #endif
            return t
        }
        #if DEBUG
        print("GITHUB_TOKEN missing")
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

    private static func summarize(_ value: String?) -> String {
        guard let value else { return "missing" }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return "empty" }
        if trimmed.contains("$(") { return "placeholder(\(trimmed))" }
        return "present(\(trimmed.count) chars)"
    }
}
