//
//  ItemCard.swift
//  FreshGuard
//
//  Created by Charlie Hebdo on 10/24/25.
//

import SwiftUI

/// Reusable pantry item card. Independent from storage/state.
struct ItemCard: View {
    struct Model: Identifiable, Equatable, Hashable {
        let id: UUID
        var name: String
        var locationPath: String
        var qty: Int
        var daysToExpire: Int?
        var status: ItemStatus
        var opened: Bool
        var image: Image?

        init(
            id: UUID = UUID(),
            name: String,
            locationPath: String,
            qty: Int,
            daysToExpire: Int?,
            status: ItemStatus,
            opened: Bool,
            image: Image?
        ) {
            self.id = id
            self.name = name
            self.locationPath = locationPath
            self.qty = qty
            self.daysToExpire = daysToExpire
            self.status = status
            self.opened = opened
            self.image = image
        }

        // Only id participates
        static func == (lhs: Model, rhs: Model) -> Bool { lhs.id == rhs.id }
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }


    var model: Model
    var onUse: (() -> Void)?
    var onMove: (() -> Void)?

    init(model: Model, onUse: (() -> Void)? = nil, onMove: (() -> Void)? = nil) {
        self.model = model
        self.onUse = onUse
        self.onMove = onMove
    }

    private var expiryText: String {
        if let d = model.daysToExpire {
            return d == 0 ? "Expires in 0d" : "Expires in \(d)d"
        } else { return "No date" }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 84, height: 84)
                    .overlay(
                        model.image?
                            .resizable()
                            .scaledToFill()
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                if model.opened {
                    Text("Opened")
                        .font(.caption2).bold()
                        .padding(.horizontal, 6).padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(6)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(model.name).font(.headline)
                        Text(model.locationPath)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    StatusBadge(status: model.status)
                }

                HStack {
                    Text("Qty: \(model.qty)")
                        .font(.subheadline)
                    Spacer()
                    Text(expiryText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    if let onUse { Button("Use one", action: onUse).buttonStyle(.bordered) }
                    if let onMove { Button("Move", action: onMove).buttonStyle(.bordered) }
                }
                .padding(.top, 2)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.black.opacity(0.06))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(model.name), quantity \(model.qty), status \(model.status.label), \(expiryText)")
    }
}

// MARK: - Convenience init from your domain model

extension ItemCard {
    init(item: PantryItem, onUse: (() -> Void)? = nil, onMove: (() -> Void)? = nil) {
        self.init(
            model: .init(
                id: item.id,
                name: item.name,
                locationPath: item.locationPath,
                qty: item.qty,
                daysToExpire: item.daysToExpire,
                status: item.status,
                opened: item.opened,
                image: item.image
            ),
            onUse: onUse,
            onMove: onMove
        )
    }
}

// MARK: - Subviews kept local

struct StatusBadge: View {
    let status: ItemStatus
    init(status: ItemStatus) { self.status = status }

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(status.tint).frame(width: 8, height: 8)
            Text(status.label).font(.caption).bold()
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(
            Capsule().fill(status.tint.opacity(0.12))
        )
        .foregroundStyle(status.tint)
    }
}

// MARK: - Preview

#Preview("ItemCard") {
    ItemCard(
        model: .init(
            name: "Greek Yogurt",
            locationPath: "Fridge · Top shelf",
            qty: 4,
            daysToExpire: 1,
            status: .today,
            opened: true,
            image: Image(systemName: "photo")
        ),
        onUse: {},
        onMove: {}
    )
    .padding()
    .previewLayout(.sizeThatFits)
}
