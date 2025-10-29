//
//  Chip.swift
//  FreshGuard
//
//  Created by Charlie Hebdo on 10/24/25.
//


import SwiftUI

struct Chip: View {
    let title: String
    var selected: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(selected ? Color.black.opacity(0.9) : Color(.secondarySystemBackground))
                )
                .foregroundStyle(selected ? .white : .primary)
                .overlay(
                    Capsule().stroke(Color.black.opacity(0.08))
                )
        }
        .buttonStyle(.plain)
    }
}
