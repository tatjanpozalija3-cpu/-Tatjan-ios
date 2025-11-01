//
//  ContentView.swift
//  FreshGuard
//
//  Created by Charlie Hebdo on 10/20/25.
//


import SwiftUI
import WebKit

private let promoURL = URL(string: "https://expirydatealertpromo.sbs/")!

struct ContentView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var showPromo = true
    @State private var showNotice = false

    var body: some View {
        Group {
            if hasOnboarded { MainTabView() } else { OnboardingView() }
        }
        .fullScreenCover(
            isPresented: $showPromo,
            onDismiss: {
                showNotice = true
            }
        ) {
            PromoWebSheet(url: promoURL, isPresented: $showPromo)
                .ignoresSafeArea()
                .interactiveDismissDisabled(true)
        }


        .alert("Promo viewed", isPresented: $showNotice) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Thanks for checking the promo. Relaunch the app to see it again.")
        }
    }
}


struct PromoWebSheet: View {
    let url: URL
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            WebView(url: url)
                .ignoresSafeArea()
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = max(0, value.translation.height)
                        }
                        .onEnded { value in
                            if value.translation.height > 120 {
                                withAnimation(.snappy) { isPresented = false }
                            } else {
                                withAnimation(.snappy) { dragOffset = 0 }
                            }
                        }
                )
        }
        .overlay(alignment: .topTrailing) {
            Button { isPresented = false } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(.top, 28)        // moves it down
            .padding(.trailing, 12)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        let v = WKWebView()
        v.load(URLRequest(url: url))
        return v
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}


#Preview {
    ContentView()
}
