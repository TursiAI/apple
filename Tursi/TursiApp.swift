import SwiftUI

@main
struct TursiApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab: Tab = .chat

    enum Tab {
        case chat, memory, settings
    }
}
