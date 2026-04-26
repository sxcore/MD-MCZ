//
//  SearchViewModel.swift
//  MD-MCZ
//
//  Created by Michael Czerniakowski on 26/04/2026.
//

import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case loading
        case empty
        case results([GitHubRepositoryDTO])
        case error(String)
    }

    @Published private(set) var state: State = .idle
    @Published var searchText: String = "" { didSet { scheduleSearch() } }

    private let service: APIServicing
    private var task: Task<Void, Never>?

    init(service: APIServicing) {
        self.service = service
    }

    private func scheduleSearch() {
        task?.cancel()
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= APIConstants.Search.minimumQueryLength else {
            state = .idle
            return
        }
        task = Task { [service] in
            try? await Task.sleep(for: .milliseconds(APIConstants.Search.debounceMilliseconds))
            guard !Task.isCancelled else { return }
            state = .loading
            do {
                let response = try await service.searchRepositories(query: trimmed, page: 1)
                guard !Task.isCancelled else { return }
                state = response.items.isEmpty ? .empty : .results(response.items)
            } catch is CancellationError {
                // TODO: add error handling
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}
