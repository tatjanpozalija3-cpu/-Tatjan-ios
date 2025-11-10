//
//  OnboardingPage.swift
//  FreshGuard
//
//  Created by Charlie Hebdo on 10/20/25.
//


import SwiftUI
import UserNotifications

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
}

struct OnboardingView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var index = 0

    private let pages: [OnboardingPage] = [
//        .init(icon: "barcode.viewfinder",
//              title: "Track food the smart way",
//              subtitle: "Scan barcodes or add quickly to keep an eye on expiry dates."),
        .init(icon: "checkmark.seal",
              title: "Use first, waste less",
              subtitle: "FIFO suggestions show what to eat first across shelves and containers."),
        .init(icon: "bell.badge",
              title: "Timely reminders",
              subtitle: "Get a daily digest or pings when something is due today.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            topBar
            TabView(selection: $index) {
                ForEach(Array(pages.enumerated()), id: \.offset) { i, page in
                    pageView(page).tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            bottomArea
        }
        .animation(.easeInOut, value: index)
    }

    private var topBar: some View {
        HStack {
            Label("FreshGuard", systemImage: "circle.fill")
                .foregroundStyle(.teal)
                .font(.headline)
            Spacer()
            if index < pages.count - 1 {
                Button("Skip") { hasOnboarded = true }
                    .font(.subheadline)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack {
            LinearGradient(colors: [.mint.opacity(0.25), .clear],
                           startPoint: .top, endPoint: .center)
                .frame(height: 160)
                .overlay(
                    Image(systemName: page.icon)
                        .font(.system(size: 64, weight: .regular))
                        .foregroundStyle(.teal)
                )

            VStack(spacing: 10) {
                Text(page.title)
                    .font(.title2).bold()
                    .multilineTextAlignment(.center)
                Text(page.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                Dots(current: index, count: pages.count)
                    .padding(.top, 6)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    private var bottomArea: some View {
        VStack(spacing: 12) {
            if index < pages.count - 1 {
                HStack(spacing: 12) {
                    Button("Back") { index = max(index - 1, 0) }
                        .buttonStyle(.bordered)
                        .disabled(index == 0)

                    Button("Continue") { index = min(index + 1, pages.count - 1) }
                        .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    Button("Get started") { hasOnboarded = true }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)

                    Button("Enable notifications") { requestNotifications() }
                        .buttonStyle(.bordered)
                        .padding(.horizontal)
                }
            }

            VStack(spacing: 2) {
                Text("By continuing you agree to our ")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    .font(.footnote)
            }
            .padding(.bottom, 8)
        }
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
}

struct Dots: View {
    let current: Int
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .fill(i == current ? Color.primary : Color.secondary.opacity(0.25))
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityHidden(true)
    }
}

// Example app entry


#Preview {
    OnboardingView()
}
