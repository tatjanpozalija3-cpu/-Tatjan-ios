//
//  StatsView.swift
//  FreshGuard
//
//  Created by Charlie Hebdo on 10/20/25.
//

import SwiftUI
import UserNotifications
import StoreKit

struct SettingsView: View {
    // Persisted app settings
    @AppStorage("pushEnabled") private var pushEnabled = false
    @AppStorage("digestEnabled") private var digestEnabled = false
    @AppStorage("digestHour") private var digestHour: Int = 9
    @AppStorage("digestMinute") private var digestMinute: Int = 0

    @State private var showClearAlert = false
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Settings")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                SectionHeader("NOTIFICATIONS")
                Card {
                    RowWithToggle(
                        icon: "bell",
                        title: "Push notifications",
                        subtitle: "Reminders about expiring items",
                        isOn: $pushEnabled
                    ) { isOn in
                        if isOn { requestNotificationPermission() }
                        if !isOn { digestEnabled = false }
                    }

                    Divider().padding(.horizontal, 16)

                    RowDigest(
                        isEnabled: pushEnabled,
                        digestEnabled: $digestEnabled,
                        hour: $digestHour,
                        minute: $digestMinute
                    )
                }

                SectionHeader("DATA & PRIVACY")
                Card {
                    RowWithAccessory(
                        icon: "trash",
                        title: "Clear all data",
                        subtitle: "Remove items, locations, and settings from this device",
                        accessoryTitle: "Clear",
                        role: .destructive
                    ) { showClearAlert = true }

                    Divider().padding(.horizontal, 16)

                    RowWithAccessory(
                        icon: "shield",
                        title: "Privacy Policy",
                        subtitle: "Read how we handle your data",
                        accessoryTitle: "Open"
                    ) {
                        openURL(URL(string: "https://example.com/privacy")!)
                    }
                }

                SectionHeader("FEEDBACK")
                Card {
                    RowWithAccessory(
                        icon: "star",
                        title: "Rate this app",
                        subtitle: "Leave a review on the App Store",
                        accessoryTitle: "Rate"
                    ) { requestReview() }
                }

                Spacer(minLength: 24)
            }
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
        .alert("Clear all data?", isPresented: $showClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) { clearAllData() }
        } message: {
            Text("This removes local items, locations, and settings from this device.")
        }
    }

    // MARK: - Actions

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    private func clearAllData() {
        // Wipe your stores here.
        // Example: reset persisted flags as a placeholder.
        pushEnabled = false
        digestEnabled = false
        digestHour = 9
        digestMinute = 0
    }
}

// MARK: - Components

private struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}

private struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.black.opacity(0.06))
            )
            .padding(.horizontal)
    }
}

private struct LeadingIcon: View {
    let systemName: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .frame(width: 36, height: 36)
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
        }
    }
}

private struct RowWithToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    var onChange: (Bool) -> Void = { _ in }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            LeadingIcon(systemName: icon)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { isOn = $0; onChange($0) }
            ))
            .labelsHidden()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

private struct RowDigest: View {
    var isEnabled: Bool
    @Binding var digestEnabled: Bool
    @Binding var hour: Int
    @Binding var minute: Int

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            LeadingIcon(systemName: "clock")
            VStack(alignment: .leading, spacing: 2) {
                Text("Daily digest").font(.headline)
                Text("Top expiring items once a day")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { digestEnabled && isEnabled },
                set: { newValue in
                    digestEnabled = newValue && isEnabled
                })
            )
            .labelsHidden()
            .disabled(!isEnabled)

            TimePill(hour: $hour, minute: $minute)
                .opacity(isEnabled && digestEnabled ? 1 : 0.4)
                .allowsHitTesting(isEnabled && digestEnabled)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

private struct TimePill: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @State private var showPicker = false

    private var timeString: String {
        let comps = DateComponents(hour: hour, minute: minute)
        let date = Calendar.current.date(from: comps) ?? Date()
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    var body: some View {
        Button {
            showPicker = true
        } label: {
            Text(timeString)
                .font(.subheadline)
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(Capsule().fill(Color(.secondarySystemBackground)))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {
            TimePickerSheet(hour: $hour, minute: $minute)
                .presentationDetents([.height(280)])
        }
    }
}

private struct TimePickerSheet: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()

    var body: some View {
        VStack(spacing: 16) {
            Text("Pick time").font(.headline)
            DatePicker("", selection: Binding(
                get: {
                    Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
                },
                set: { newDate in
                    let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                    hour = comps.hour ?? 9
                    minute = comps.minute ?? 0
                }
            ), displayedComponents: .hourAndMinute)
            .datePickerStyle(.wheel)
            .labelsHidden()

            Button("Done") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

private struct RowWithAccessory: View {
    let icon: String
    let title: String
    let subtitle: String
    let accessoryTitle: String
    var role: ButtonRole? = nil
    var action: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            LeadingIcon(systemName: icon)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Button(accessoryTitle, role: role, action: action)
                .buttonStyle(.bordered)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

#Preview {
    SettingsView()
}
