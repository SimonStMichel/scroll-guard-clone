import SwiftUI

struct ContentView: View {
    @StateObject private var settings = FilterSettings()
    @StateObject private var proxy = WebViewProxy()
    @State private var showingSettings = false
    @State private var showingOnboarding = false
    @AppStorage("sg.redirectSetupDone") private var redirectSetupDone = false

    var body: some View {
        InstagramWebView(enabledRules: settings.enabledRules, proxy: proxy)
            .ignoresSafeArea(edges: .bottom)
            .overlay(alignment: .trailing) {
                settingsHandle
            }
            .overlay {
                if proxy.isLoading {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.35), value: proxy.isLoading)
            .sheet(isPresented: $showingSettings) {
                SettingsView(settings: settings, proxy: proxy)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingOnboarding) {
                NavigationStack {
                    OnboardingView()
                }
            }
            .onAppear {
                if !redirectSetupDone {
                    showingOnboarding = true
                }
            }
    }

    /// Small translucent handle flush with the trailing edge. A handle
    /// instead of a toolbar so we never cover Instagram's own top header or
    /// bottom tab bar; slightly below center so it only ever overlaps feed
    /// content, which scrolls past it anyway.
    private var settingsHandle: some View {
        Button {
            showingSettings = true
        } label: {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 34, height: 44)
                .background(
                    .thinMaterial,
                    in: UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 12)
                )
        }
        .offset(y: 90)
        .accessibilityLabel("ScrollGuard settings")
    }
}

/// Branded cover shown until the first page load finishes, so launch shows
/// this instead of a white flash while Instagram boots up. Colors match the
/// app icon.
private struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.19, green: 0.18, blue: 0.51),
                    Color(red: 0.58, green: 0.20, blue: 0.92),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 20) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 56, weight: .medium))
                    .foregroundStyle(.white)
                ProgressView()
                    .tint(.white)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
