import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        #if os(iOS)
        TabView(selection: $appState.selectedTab) {
            ChatListView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(AppState.Tab.chat)

            MemoryListView()
                .tabItem {
                    Label("Memory", systemImage: "brain")
                }
                .tag(AppState.Tab.memory)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(AppState.Tab.settings)
        }
        #else
        NavigationSplitView {
            List(selection: $appState.selectedTab) {
                Label("Chat", systemImage: "bubble.left.and.bubble.right")
                    .tag(AppState.Tab.chat)
                Label("Memory", systemImage: "brain")
                    .tag(AppState.Tab.memory)
                Label("Settings", systemImage: "gear")
                    .tag(AppState.Tab.settings)
            }
            .navigationTitle("Tursi")
        } detail: {
            switch appState.selectedTab {
            case .chat:
                ChatListView()
            case .memory:
                MemoryListView()
            case .settings:
                SettingsView()
            }
        }
        #endif
    }
}
