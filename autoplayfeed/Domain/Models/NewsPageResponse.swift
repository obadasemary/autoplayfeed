//
//  NewsPageResponse.swift
//  autoplayfeed
//
//  Created by Claude on 14.02.2026.
//

import Foundation

struct NewsPageResponse {
    let items: [NewsItem]
    let totalCount: Int
    let page: Int
    let pageSize: Int
    let hasNextPage: Bool
}
