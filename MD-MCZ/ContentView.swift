//
//  ContentView.swift
//  MD-MCZ
//
//  Created by Michael Czerniakowski on 23/04/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var query = "swift"
    @State private var isLoading = false
    @State private var logs: [String] = []
    @State private var repositories: [GitHubRepositoryDTO] = []

    private let token: String? = GitHubConfig.token

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GitHub API Debug")
                .font(.title3.bold())

            Text(authLabel)
                .font(.subheadline)
                .foregroundStyle(token == nil ? .red : .green)
            Text(GitHubConfig.diagnostics)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                TextField("Repository search query", text: $query)
                    .textFieldStyle(.roundedBorder)
                Button(isLoading ? "Loading..." : "Search") {
                    Task { await runSearch() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)
            }

            if repositories.isEmpty == false {
                Text("Results (\(repositories.count))")
                    .font(.headline)
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(repositories.prefix(10), id: \.id) { repo in
                            Text("- \(repo.fullName)")
                                .font(.footnote.monospaced())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 140)
            }

            Text("Logs")
                .font(.headline)
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(logs.indices, id: \.self) { index in
                        Text(logs[index])
                            .font(.footnote.monospaced())
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 260)
            .padding(8)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .task {
            appendLog("Screen loaded")
            appendLog(GitHubConfig.diagnostics)
            appendLog(authLabel)
        }
    }

    private var authLabel: String {
        if let token {
            return "Authenticated: token found (\(token.count) chars)"
        }
        return "Not authenticated: no GITHUB_TOKEN in Info.plist/env"
    }

    @MainActor
    private func runSearch() async {
        isLoading = true
        repositories = []

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        appendLog("Search started q='\(trimmed)'")

        let service = APIService(authToken: token)
        do {
            let response = try await service.searchRepositories(query: trimmed, page: 1)
            repositories = response.items
            appendLog("Success: totalCount=\(response.totalCount), items=\(response.items.count)")
        } catch APIError.httpStatus(let code, let data) {
            appendLog("HTTP \(code)")
            if let body = String(data: data, encoding: .utf8), body.isEmpty == false {
                appendLog("Body: \(body)")
            }
        } catch {
            appendLog("Error: \(error.localizedDescription)")
        }

        isLoading = false
    }

    @MainActor
    private func appendLog(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        logs.append("[\(formatter.string(from: Date()))] \(message)")
    }
}

#Preview {
    ContentView()
}
