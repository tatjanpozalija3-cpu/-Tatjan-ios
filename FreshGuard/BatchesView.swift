//
//  BatchesView.swift
//  FreshGuard
//
//  Created by Charlie Hebdo on 10/20/25.
//

import SwiftUI

// MARK: - Model

enum BatchStatus: CaseIterable, Identifiable {
    case ok, soon, today, urgent, expired
    var id: Self { self }

    var label: String {
        switch self {
        case .ok: "OK"
        case .soon: "Soon"
        case .today: "Today"
        case .urgent: "Urgent"
        case .expired: "Expired"
        }
    }
    var color: Color {
        switch self {
        case .ok: .green
        case .soon: .yellow
        case .today: .orange
        case .urgent: .red
        case .expired: .gray
        }
    }
}

struct Batch: Identifiable {
    let id = UUID()
    var name: String
    var countLabel: String      // "4 packs"
    var locationPath: String    // "Freezer — Drawer · Drawer B"
    var nearestDays: Int        // 0..n
    var opened: Int
    var total: Int
    var status: BatchStatus
    var progress: Double        // 0...1
}

// MARK: - Filter

enum BatchFilter: String, CaseIterable, Identifiable {
    case all = "All", ok = "Ok", soon = "Soon", today = "Today", urgent = "Urgent", expired = "Expired"
    var id: String { rawValue }
    func match(_ b: Batch) -> Bool {
        switch self {
        case .all: true
        case .ok: b.status == .ok
        case .soon: b.status == .soon
        case .today: b.status == .today
        case .urgent: b.status == .urgent
        case .expired: b.status == .expired
        }
    }
}

// MARK: - View

struct BatchesView: View {
    @State private var search = ""
    @State private var filter: BatchFilter = .all
    @State private var data: [Batch] = demoBatches
    @State private var showAdd = false

    private var filtered: [Batch] {
        data.filter { b in
            (search.isEmpty || b.name.localizedCaseInsensitiveContains(search)) && filter.match(b)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(filtered) { b in
                        BatchCard(b: b)
                    }
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showAdd) {
            AddBatchView { new in
                data.append(new)
            }
        }
    }

    // Header + search + chips
    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Batches").font(.title3).bold()
                Spacer()
                Button {} label: { Image(systemName: "slider.horizontal.3") }
            }
            HStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search by product", text: $search)
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

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(BatchFilter.allCases) { f in
                        let count = data.filter { f == .all ? true : f.match($0) }.count
                        BatchChip(title: "\(f.rawValue) \(count)", selected: filter == f) {
                            filter = f
                        }
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
}

// MARK: - Components

struct BatchChip: View {
    let title: String
    var selected = false
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(
                    Capsule().fill(selected ? Color.primary : Color(.secondarySystemBackground))
                )
                .foregroundStyle(selected ? .white : .primary)
                .overlay(Capsule().stroke(.black.opacity(0.08)))
        }
        .buttonStyle(.plain)
    }
}

struct StatusPill: View {
    let status: BatchStatus
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(status.color).frame(width: 8, height: 8)
            Text(status.label).font(.caption).bold()
        }
        .padding(.horizontal, 8).padding(.vertical, 5)
        .background(Capsule().fill(status.color.opacity(0.12)))
        .foregroundStyle(status.color)
    }
}

struct FreshnessBar: View {
    let progress: Double
    let tint: Color
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color(.systemGray5))
                Capsule()
                    .fill(LinearGradient(colors: [tint.opacity(0.9), tint.opacity(0.6)],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(6, geo.size.width * CGFloat(progress)))
            }
        }
        .frame(height: 8)
        .clipShape(Capsule())
    }
}

struct BatchCard: View {
    let b: Batch

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(b.name).font(.headline)
                    Text("\(b.countLabel) · \(b.locationPath)")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    StatusPill(status: b.status)
                    Text("Nearest: \(b.nearestDays)d")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            FreshnessBar(progress: b.progress, tint: b.status.color)

            HStack {
                Text("Opened: \(b.opened) / \(b.total)")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Button("− Use 1") {}.buttonStyle(.bordered)
                    Button("→ Move") {}.buttonStyle(.bordered)
                    Button("+ Split") {}.buttonStyle(.bordered)
                }
                Button("× Merge") {}.buttonStyle(.bordered)
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

// MARK: - Add Sheet

struct AddBatchView: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (Batch) -> Void

    @State private var name = ""
    @State private var countLabel = ""
    @State private var locationPath = ""
    @State private var nearestDays = 0
    @State private var opened = 0
    @State private var total = 1
    @State private var status: BatchStatus = .ok
    @State private var freshness = 0.8

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Name", text: $name)
                    TextField("Count label (e.g. 4 packs)", text: $countLabel)
                    TextField("Location path", text: $locationPath)
                }
                Section("Dates & status") {
                    Stepper("Nearest: \(nearestDays) days", value: $nearestDays, in: 0...365)
                    Picker("Status", selection: $status) {
                        ForEach(BatchStatus.allCases) { s in
                            Text(s.label).tag(s)
                        }
                    }
                }
                Section("Counts") {
                    Stepper("Opened: \(opened)", value: $opened, in: 0...999)
                    Stepper("Total: \(total)", value: $total, in: 1...999)
                }
                Section("Freshness") {
                    Slider(value: $freshness, in: 0...1)
                }
            }
            .navigationTitle("+ Add Batch")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(.init(name: name,
                                     countLabel: countLabel.isEmpty ? "1 unit" : countLabel,
                                     locationPath: locationPath.isEmpty ? "Unassigned" : locationPath,
                                     nearestDays: nearestDays,
                                     opened: opened,
                                     total: max(total, opened),
                                     status: status,
                                     progress: min(max(freshness, 0), 1)))
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Demo

private let demoBatches: [Batch] = [
    .init(name: "Greek Yogurt",
          countLabel: "4 packs",
          locationPath: "Fridge — Top shelf",
          nearestDays: 0, opened: 2, total: 4,
          status: .today, progress: 0.85),
    .init(name: "Chicken Breast",
          countLabel: "4 packs",
          locationPath: "Freezer — Drawer · Drawer B",
          nearestDays: 14, opened: 0, total: 4,
          status: .ok, progress: 0.95),
    .init(name: "Strawberries",
          countLabel: "3 boxes",
          locationPath: "Fridge — Box A",
          nearestDays: 1, opened: 1, total: 3,
          status: .urgent, progress: 0.35),
    .init(name: "Mozzarella",
          countLabel: "5 pcs",
          locationPath: "Fridge — Door",
          nearestDays: 3, opened: 0, total: 5,
          status: .soon, progress: 0.6),
]

#Preview { BatchesView() }
