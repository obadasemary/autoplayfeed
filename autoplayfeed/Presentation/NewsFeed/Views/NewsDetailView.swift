//
//  NewsDetailView.swift
//  autoplayfeed
//
//  Created by Claude Code on 14.02.2026.
//

import SwiftUI

/// Detail view displaying full news article content
struct NewsDetailView: View {
    let item: NewsItemAdapter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header image
                if let imageURL = item.imageURL {
                    AsyncImage(url: imageURL) { phase in
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
                                        .font(.largeTitle)
                                        .foregroundStyle(.gray)
                                }
                        @unknown default:
                            Color.gray.opacity(0.3)
                        }
                    }
                    .frame(height: 250)
                    .clipShape(Rectangle())
                }

                VStack(alignment: .leading, spacing: 16) {
                    // Category badge
                    Text(item.category)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue, in: Capsule())

                    // Title
                    Text(item.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    // Metadata row
                    HStack(spacing: 12) {
                        // Author
                        HStack(spacing: 4) {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(.secondary)
                            Text(item.author)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        // Date
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .foregroundStyle(.secondary)
                            Text(item.formattedDate)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    // Source
                    HStack(spacing: 4) {
                        Image(systemName: "newspaper")
                            .foregroundStyle(.secondary)
                        Text(item.source)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Description/Content
                    Text(item.description)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineSpacing(6)
                        .padding(.top, 8)

                    // Tags
                    if !item.tags.isEmpty {
                        Divider()
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            FlowLayout(spacing: 8) {
                                ForEach(item.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .foregroundStyle(.blue)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.blue.opacity(0.1), in: Capsule())
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    // Share functionality placeholder
                    print("Share news: \(item.title)")
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

// MARK: - Flow Layout

/// Custom layout that flows items horizontally with wrapping
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: .unspecified)
        }
    }

    struct FlowResult {
        var positions: [CGPoint] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    // Move to next line
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NewsDetailView(
            item: NewsItemAdapter(
                id: "1",
                title: "AI Breakthrough: New Model Achieves Human-Level Performance",
                description: "Researchers announce a revolutionary AI model that performs on par with humans across multiple benchmarks. This breakthrough represents years of research and could transform how we interact with technology. The model demonstrates unprecedented understanding of context, nuance, and complex reasoning tasks that were previously thought to be uniquely human capabilities.",
                imageURL: URL(string: "https://picsum.photos/400/300"),
                formattedDate: "2 hours ago",
                source: "Tech News Daily",
                category: "Technology",
                author: "Jane Smith",
                tags: ["AI", "Research", "Machine Learning", "Innovation"]
            )
        )
    }
}
