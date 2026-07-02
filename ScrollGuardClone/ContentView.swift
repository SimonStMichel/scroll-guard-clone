import SwiftUI

struct ContentView: View {
    @StateObject private var settings = FilterSettings()
    @StateObject private var proxy = WebViewProxy()
    @State private var showingSettings = false

    var body: some View {
        InstagramWebView(enabledRules: settings.enabledRules, proxy: proxy)
            .ignoresSafeArea(edges: .bottom)
            .overlay(alignment: .trailing) {
                settingsHandle
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(settings: settings, proxy: proxy)
                    .presentationDetents([.medium, .large])
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

#Preview {
    ContentView()
}
