//
//  LocationsView.swift
//  FreshGuard
//
//  Created by Charlie Hebdo on 10/20/25.
//

import SwiftUI

// MARK: - Models

enum LocationKind: CaseIterable, Identifiable {
    case fridge, freezer, pantry
    var id: Self { self }
    var label: String {
        switch self {
        case .fridge:  "Fridge"
        case .freezer: "Freezer"
        case .pantry:  "Pantry"
        }
    }
    var tint: Color {
        switch self {
        case .fridge:  .blue
        case .freezer: .teal
        case .pantry:  .yellow
        }
    }
    var icon: String {
        // Use "refrigerator" on iOS 18+, fallback otherwise if needed
        switch self {
        case .fridge:  "refrigerator"
        case .freezer: "snowflake"
        case .pantry:  "rectangle.grid.2x2"
        }
    }
}

struct StorageLocation: Identifiable {
    let id = UUID()
    var title: String          // e.g., "Fridge — Kitchen"
    var subtitle: String       // e.g., "4 shelves · 26 items"
    var kind: LocationKind
    var temp: String?          // "+4°C", "-18°C"
}

// MARK: - View

struct LocationsView: View {
    @State private var search = ""
    @State private var data: [StorageLocation] = demoLocations
    @State private var showAdd = false

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(filtered) { loc in
                        LocationCard(loc: loc)
                    }
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showAdd) {
            AddLocationView { new in
                data.append(new)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Locations").font(.title3).bold()
                Spacer()
            }
            HStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search locations", text: $search)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.black.opacity(0.08)))

                Button { showAdd = true } label: {
                    HStack(spacing: 6) { Image(systemName: "plus"); Text("Add") }
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private var filtered: [StorageLocation] {
        guard !search.isEmpty else { return data }
        return data.filter { $0.title.localizedCaseInsensitiveContains(search) }
    }
}

// MARK: - Components

struct LocationCard: View {
    let loc: StorageLocation

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 44, height: 44)
                    Image(systemName: loc.kind.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(loc.title).font(.headline)
                        Spacer()
                        Tag(text: loc.kind.label, tint: loc.kind.tint)
                        Image(systemName: "chevron.right")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Text(loc.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 8) {
                if let t = loc.temp { SmallPill(text: t) }
                SmallPill(text: "Quick audit")
                Spacer(minLength: 0)
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
    }
}

struct Tag: View {
    let text: String
    let tint: Color
    var body: some View {
        Text(text)
            .font(.caption).bold()
            .padding(.horizontal, 8).padding(.vertical, 5)
            .background(Capsule().fill(tint.opacity(0.12)))
            .foregroundStyle(tint)
    }
}

struct SmallPill: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(Capsule().fill(Color(.secondarySystemBackground)))
    }
}

// MARK: - Add Sheet

struct AddLocationView: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (StorageLocation) -> Void

    @State private var title = ""
    @State private var subtitle = ""
    @State private var kind: LocationKind = .fridge
    @State private var temp = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Title", text: $title)
                    TextField("Subtitle", text: $subtitle)
                    Picker("Type", selection: $kind) {
                        ForEach(LocationKind.allCases) { k in
                            Text(k.label).tag(k)
                        }
                    }
                }
                Section("Temperature") {
                    TextField("e.g. +4°C or -18°C", text: $temp)
                }
            }
            .navigationTitle("Add Location")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(.init(title: title,
                                     subtitle: subtitle.isEmpty ? "0 shelves · 0 items" : subtitle,
                                     kind: kind,
                                     temp: temp.isEmpty ? nil : temp))
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// MARK: - Demo

private let demoLocations: [StorageLocation] = [
    .init(title: "Fridge — Kitchen",  subtitle: "4 shelves · 26 items", kind: .fridge,  temp: "+4°C"),
    .init(title: "Freezer — Drawer",  subtitle: "2 shelves · 13 items", kind: .freezer, temp: "-18°C"),
    .init(title: "Pantry — Hall",     subtitle: "3 shelves · 15 items", kind: .pantry,  temp: nil),
]

#Preview { LocationsView() }
