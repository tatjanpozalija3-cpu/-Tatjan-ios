//
//  HomeView.swift
//  FreshGuard
//
//  Created by Charlie Hebdo on 10/20/25.
//

import SwiftUI

// MARK: - Models

enum ExpiryFilter: String, CaseIterable, Identifiable {
    case all = "All", soon = "Soon", today = "Today", urgent = "Urgent", expired = "Expired"
    var id: String { rawValue }
}

// add conformance for pickers
enum ItemStatus: CaseIterable, Identifiable {
    case today, ok, urgent, soon, expired
    var id: Self { self }

    var label: String {
        switch self {
        case .today:  return "Today"
        case .ok:     return "OK"
        case .urgent: return "Urgent"
        case .soon:   return "Soon"
        case .expired:return "Expired"
        }
    }
    var tint: Color {
        switch self {
        case .today:  return .orange
        case .ok:     return .green
        case .urgent: return .red
        case .soon:   return .yellow
        case .expired:return .gray
        }
    }
}

struct PantryItem: Identifiable {
    let id = UUID()
    let name: String
    let locationPath: String
    let qty: Int
    let daysToExpire: Int?
    let status: ItemStatus
    let opened: Bool
    let image: Image?
}

// MARK: - Home

struct HomeView: View {
    private enum Route: Hashable { case addItem }

    @State private var search = ""
    @State private var filter: ExpiryFilter = .all
    @State private var navPath: [Route] = []

    // make items mutable so we can append
    @State private var items: [PantryItem] = demoItems

    private var filtered: [PantryItem] {
        items.filter { item in
            let matchesSearch = search.isEmpty || item.name.localizedCaseInsensitiveContains(search)
            guard matchesSearch else { return false }
            switch filter {
            case .all: return true
            case .soon: return item.status == .soon
            case .today: return item.status == .today
            case .urgent: return item.status == .urgent
            case .expired: return item.status == .expired
            }
        }
    }

    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        searchBar
                        chips
                        ForEach(filtered) { item in
                            ItemCard(item: item)
                        }
                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                Button {
                    navPath.append(.addItem)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .padding(18)
                        .background(Circle().fill(.black))
                        .foregroundStyle(.white)
                        .shadow(radius: 6, y: 3)
                }
                .padding(.trailing, 18)
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("FreshGuard")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .addItem:
                    AddItemView(items: $items)
                }
            }
        }
    }

    // MARK: UI pieces (unchanged below except they use `items`)
    private var header: some View { /* ... your existing header ... */
        VStack(alignment: .leading, spacing: 6) {
            Text("Today").font(.footnote).foregroundStyle(.secondary)
            HStack {
                Text("Soon to Expire").font(.title2).bold()
                Spacer()
            }
        }
    }

    private var searchBar: some View { /* unchanged */
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                TextField("Search products", text: $search)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.black.opacity(0.08)))


        }
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ExpiryFilter.allCases) { f in
                    let count = countForFilter(f)
                    Chip(title: "\(f.rawValue) \(count)", selected: filter == f) {
                        filter = f
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }

    private func countForFilter(_ f: ExpiryFilter) -> Int {
        switch f {
        case .all: return items.count
        case .soon: return items.filter{ $0.status == .soon }.count
        case .today: return items.filter{ $0.status == .today }.count
        case .urgent: return items.filter{ $0.status == .urgent }.count
        case .expired: return items.filter{ $0.status == .expired }.count
        }
    }
}

// MARK: - Add Item screen

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var items: [PantryItem]

    @State private var name = ""
    @State private var locationPath = ""
    @State private var qty = 1
    @State private var daysToExpire: String = ""
    @State private var status: ItemStatus = .ok
    @State private var opened = false

    var body: some View {
        Form {
            Section("Basics") {
                TextField("Name", text: $name)
                TextField("Location (e.g. Fridge · Top shelf)", text: $locationPath)
                Stepper("Quantity: \(qty)", value: $qty, in: 1...999)
                Picker("Status", selection: $status) {
                    ForEach(ItemStatus.allCases) { s in
                        Text(s.label).tag(s)
                    }
                }
                Toggle("Opened", isOn: $opened)
            }
            Section("Expiry") {
                TextField("Days to expire (leave empty for unknown)", text: $daysToExpire)
                    .keyboardType(.numberPad)
            }
        }
        .navigationTitle("Add Item")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }.disabled(name.isEmpty || locationPath.isEmpty)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }

    private func save() {
        let days = Int(daysToExpire.trimmingCharacters(in: .whitespaces))
        let new = PantryItem(
            name: name,
            locationPath: locationPath,
            qty: qty,
            daysToExpire: days,
            status: status,
            opened: opened,
            image: Image(systemName: "photo")
        )
        items.append(new)
        dismiss()
    }
}

// MARK: - Components (your existing Chip, StatusBadge, ItemCard) remain the same
// ...

private let demoItems: [PantryItem] = [
    .init(name: "Greek Yogurt", locationPath: "Fridge · Top shelf", qty: 4, daysToExpire: 1, status: .today, opened: true, image: Image(systemName: "photo")),
    .init(name: "Chicken Breast", locationPath: "Freezer · Drawer B", qty: 2, daysToExpire: 7, status: .ok, opened: false, image: Image(systemName: "photo")),
    .init(name: "Strawberries", locationPath: "Fridge · Box A", qty: 1, daysToExpire: 0, status: .urgent, opened: true, image: Image(systemName: "photo")),
    .init(name: "Mozzarella", locationPath: "Fridge · Door", qty: 3, daysToExpire: 3, status: .soon, opened: false, image: Image(systemName: "photo"))
]

#Preview { HomeView() }
