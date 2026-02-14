//
//  NewsItemRowView.swift
//  autoplayfeed
//
//  Created by Claude Code on 13.02.2026.
//

import SwiftUI

/// View component for displaying a single news item row
struct NewsItemRowView: View {
    let item: NewsItemAdapter

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // News image
            AsyncImage(url: item.imageURL) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.3)
                        .overlay {
                            ProgressView()
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Color.gray.opacity(0.3)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.gray)
                        }
                @unknown default:
                    Color.gray.opacity(0.3)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // News content
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                // Description
                Text(item.description)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)

                // Category badge
                Text(item.category)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1), in: Capsule())

                Spacer()

                // Footer with source and date
                HStack {
                    Text(item.source)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(item.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        NewsItemRowView(
            item: NewsItemAdapter(
                id: "1",
                title: "Breaking News: Major Discovery in AI",
                description: "Scientists have made a groundbreaking discovery that could revolutionize artificial intelligence as we know it.",
                imageURL: URL(string: "https://picsum.photos/200"),
                formattedDate: "2 hours ago",
                source: "Tech News",
                category: "Technology",
                author: "John Doe",
                tags: ["AI", "Technology"]
            )
        )
    }
}
