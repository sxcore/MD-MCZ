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

    @Published private(set) var state: SearchState = .idle
    @Published var searchText: String = "" { didSet { scheduleSearch() } }
    let prompt: String = "Search GitHub users and repositories"

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
                let items = try await service.searchAutocomplete(query: trimmed)
                guard !Task.isCancelled else { return }
                state = items.isEmpty ? .empty : .results(items)
            } catch {
                guard !Task.isCancelled else { return }
                state = .error(error.localizedDescription)
            }
        }
    }
}
