//
//  HTTPURLResponse+Status.swift
//  MD-MCZ
//
//  Created by Michał Czerniakowski on 24/04/2026.
//

import Foundation

extension HTTPURLResponse {
	var isSuccessful: Bool {
		(200 ..< 300).contains(statusCode)
	}
}
