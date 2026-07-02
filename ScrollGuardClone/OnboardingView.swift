import SwiftUI

/// Step-by-step walkthrough for the one thing the app can't do itself:
/// creating the Shortcuts automation that redirects the native Instagram app
/// here. Apple provides no API for creating personal automations, so this is
/// a one-time manual setup (~30 seconds).
///
/// Shown automatically on first launch (wrapped in a sheet by ContentView)
/// and reachable any time from the settings sheet.
struct OnboardingView: View {
    /// Set when the user confirms the redirect works; ContentView reads it
    /// to decide whether to auto-present this on launch.
    @AppStorage("sg.redirectSetupDone") private var redirectSetupDone = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private struct Step {
        let title: String
        let detail: String
    }

    private let steps: [Step] = [
        Step(
            title: "Open the Shortcuts app",
            detail: "It comes preinstalled on every iPhone. If you removed it, reinstall it from the App Store."
        ),
        Step(
            title: "Go to Automation, tap +",
            detail: "The Automation tab is at the bottom of the Shortcuts app."
        ),
        Step(
            title: "Choose the \"App\" trigger",
            detail: "Scroll the list of triggers and pick App."
        ),
        Step(
            title: "Select Instagram · Is Opened",
            detail: "Tap \"Choose\" next to App and pick Instagram. Leave \"Is Opened\" checked."
        ),
        Step(
            title: "Run Immediately",
            detail: "Pick \"Run Immediately\" and switch off \"Notify When Run\", then tap Next. Labels vary slightly between iOS versions."
        ),
        Step(
            title: "Add the \"Open App\" action",
            detail: "Tap \"New Blank Automation\", then \"Add Action\", search for \"Open App\", tap the faint App token and choose ScrollGuard Clone."
        ),
        Step(
            title: "Tap Done, then try it",
            detail: "Open Instagram — it should bounce you straight back into ScrollGuard Clone."
        ),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("The app can't modify Instagram itself — instead, a Shortcuts automation reopens ScrollGuard Clone whenever Instagram launches. You keep Instagram installed, so notifications and DMs still work.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                ForEach(steps.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 14) {
                        Text("\(index + 1)")
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(.tint))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(steps[index].title)
                                .font(.headline)
                            Text(steps[index].detail)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Text("To pause the redirect later, open Shortcuts → Automation, tap the automation, and disable or delete it.")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)

                VStack(spacing: 12) {
                    Button {
                        openURL(URL(string: "shortcuts://")!)
                    } label: {
                        Label("Open Shortcuts", systemImage: "arrow.up.forward.app")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        redirectSetupDone = true
                        dismiss()
                    } label: {
                        Text("It works — I'm done")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle("Redirect setup")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Later") { dismiss() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingView()
    }
}
