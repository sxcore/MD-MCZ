//
//  SearchScreen.swift
//  MD-MCZ
//
//  Created by Michael Czerniakowski on 27/04/2026.
//

import SwiftUI

struct SearchScreen: View {
    private let service: APIServicing
    private let title: String
    private let onSelect: ((SearchItem) -> Void)?

    init(
        service: APIServicing = APIService(),
        title: String = "Search",
        onSelect: ((SearchItem) -> Void)? = nil
    ) {
        self.service = service
        self.title = title
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationStack {
            SearchView(service: service, onSelect: onSelect)
                .navigationTitle(title)
        }
    }
}
