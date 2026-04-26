//
//  GHSearchViewModel.swift
//  MD-MCZ
//
//  Created by Michael Czerniakowski on 26/04/2026.
//

import Foundation
internal import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    
    enum State {
        case idle
        case loading
        case empty
        case results ([GitHubRepositoryDTO])
        case error(String)
    }
    
    init(state: State,
         searchText: String,
         service: APIServicing,
         task: Task<Void,
         Never>? = nil
    ) {
        self.state = state
        self.searchText = searchText
        self.service = service
        self.task = task
    }
    
    @Published private(set) var state: State = .idle
    @Published var searchText: String = "" { didSet { scheduleSearch() } }
    
    private let service: APIServicing
    private var task: Task<Void, Never>?
    
    private func scheduleSearch() {
        task?.cancel()
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= APIConstants.Search.minimumQueryLength else {
            state = .idle
            return
        }
        task = Task { [service] in
            try? await Task.sleep(for: .milliseconds(APIConstants.Search.sleepTime))
            guard !Task.isCancelled else { return }
            state = .loading
            do {
                let response = try await service.self.searchRepositories(query: trimmed, page: 1)
                guard !Task.isCancelled else { return }
                state = response.items.isEmpty ? .empty : .results(response.items)
            } catch is CancellationError {
                
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
     
}
