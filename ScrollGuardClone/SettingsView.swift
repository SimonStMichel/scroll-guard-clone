import SwiftUI

/// The sheet behind the edge handle: per-filter toggles plus the few
/// navigation actions the web view needs (Instagram web has no reliable
/// "go home" affordance once you're deep in a profile or a post).
struct SettingsView: View {
    @ObservedObject var settings: FilterSettings
    let proxy: WebViewProxy
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(FilterRule.all) { rule in
                        Toggle(rule.title, isOn: binding(for: rule))
                    }
                } header: {
                    Text("Filters")
                } footer: {
                    Text("Changing a filter reloads the page.")
                }

                Section("Navigation") {
                    Button {
                        proxy.goHome()
                        dismiss()
                    } label: {
                        Label("Home feed", systemImage: "house")
                    }
                    Button {
                        proxy.goBack()
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.backward")
                    }
                    Button {
                        proxy.reload()
                        dismiss()
                    } label: {
                        Label("Reload", systemImage: "arrow.clockwise")
                    }
                }
            }
            .navigationTitle("ScrollGuard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func binding(for rule: FilterRule) -> Binding<Bool> {
        Binding(
            get: { settings.isEnabled(rule) },
            set: { settings.setEnabled($0, for: rule) }
        )
    }
}

#Preview {
    SettingsView(settings: FilterSettings(), proxy: WebViewProxy())
}
