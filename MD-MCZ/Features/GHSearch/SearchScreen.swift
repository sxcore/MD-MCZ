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

    init(
        service: APIServicing = APIService(),
        title: String = "Search"
    ) {
        self.service = service
        self.title = title
    }

    var body: some View {
        NavigationStack {
            SearchView(service: service)
                .navigationTitle(title)
        }
    }
}
