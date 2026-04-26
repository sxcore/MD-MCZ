//
//  SearchView.swift
//  MD-MCZ
//
//  Created by Michael Czerniakowski on 26/04/2026.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    
    init(service: APIServicing = APIService()) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(service: service))
    }
    
    var body: some View {
        NavigationStack {
            content
              .searchable(text: $viewModel.searchText, prompt: "Search GitHub repositories")
              .navigationTitle("Search")
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        default: EmptyView()
        }
    }
    
}
