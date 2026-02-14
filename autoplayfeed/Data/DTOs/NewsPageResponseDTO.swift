//
//  NewsPageResponseDTO.swift
//  autoplayfeed
//
//  Created by Claude on 14.02.2026.
//

import Foundation

struct NewsPageResponseDTO: Codable {
    let items: [NewsItemDTO]
    let totalCount: Int
    let page: Int
    let pageSize: Int
    let hasNextPage: Bool

    enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
        case page
        case pageSize = "page_size"
        case hasNextPage = "has_next_page"
    }
}
