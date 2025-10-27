//
//  ContentView.swift
//  FreshGuard
//
//  Created by Charlie Hebdo on 10/20/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    var body: some View {
        Group {
            if hasOnboarded {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
    }
}

#Preview {
    ContentView()
}
