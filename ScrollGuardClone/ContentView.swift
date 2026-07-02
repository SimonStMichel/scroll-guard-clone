import SwiftUI

struct ContentView: View {
    var body: some View {
        InstagramWebView()
            .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    ContentView()
}
