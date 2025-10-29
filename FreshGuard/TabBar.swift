//
//  TabBar.swift
//  FreshGuard
//
//  Created by Charlie Hebdo on 10/20/25.
//

import SwiftUI

// MARK: - Tabs

enum AppTab: String, CaseIterable, Identifiable {
    case home, locations, batches, stats
    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .locations: return "Locations"
        case .batches: return "Batches"
        case .stats: return "Stats"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .locations: return "mappin.and.ellipse"   // replace with your fridge asset if needed
        case .batches: return "shippingbox"
        case .stats: return "chart.bar.xaxis"
        }
    }
}

// MARK: - Root

struct MainTabView: View {
    @State private var selection: AppTab = .home

    var body: some View {
        ZStack {
            Group {
                switch selection {
                case .home: HomeView()
                case .locations: LocationsView()
                case .batches: BatchesView()
                case .stats: SettingsView()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selection: $selection)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
    }
}

// MARK: - Bar

struct CustomTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    withAnimation(.easeInOut) { selection = tab }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .regular))
                            .symbolVariant(selection == tab ? .fill : .none)
                        Text(tab.title)
                            .font(.footnote)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(selection == tab ? Color.primary : .secondary)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.06), radius: 10, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
        )
        .padding(.top, 4)
    }
}


#Preview {
    MainTabView()
}
