//
//  NewsPageResponseDTO.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import Foundation

/// Data Transfer Object for paginated news response matching API structure
struct NewsPageResponseDTO: Codable {
    let page: Int
    let totalPages: Int
    let totalItems: Int
    let items: [NewsItemDTO]
}
