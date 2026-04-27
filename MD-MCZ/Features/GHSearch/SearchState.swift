//
//  SearchState.swift
//  MD-MCZ
//
//  Created by Michael Czerniakowski on 27/04/2026.
//

import Foundation

enum SearchState: Equatable {
    case idle
    case loading
    case empty
    case results([SearchItem])
    case error(String)
}
