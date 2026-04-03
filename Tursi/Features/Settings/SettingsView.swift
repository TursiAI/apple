import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        ModelSettingsView()
                    } label: {
                        Label("AI Model", systemImage: "cpu")
                    }

                    NavigationLink {
                        IntegrationsView()
                    } label: {
                        Label("Integrations", systemImage: "puzzlepiece.extension")
                    }
                }

                Section {
                    NavigationLink {
                        PrivacyView()
                    } label: {
                        Label("Privacy & Encryption", systemImage: "lock.shield")
                    }

                    NavigationLink {
                        AccountView()
                    } label: {
                        Label("Account", systemImage: "person.circle")
                    }
                }

                Section {
                    NavigationLink {
                        MemorySettingsView()
                    } label: {
                        Label("Memory", systemImage: "brain")
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("Tursi")
                                .font(.footnote)
                                .fontWeight(.medium)
                            Text("v2.0.0")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Memory Settings

struct MemorySettingsView: View {
    @AppStorage("autoExtractMemories") private var autoExtract = true
    @AppStorage("extractionTiming") private var timing = "end"

    var body: some View {
        Form {
            Section {
                Toggle("Auto-extract memories", isOn: $autoExtract)
            } footer: {
                Text("Automatically identify and save important information from your conversations.")
            }

            if autoExtract {
                Section("Timing") {
                    Picker("Extract memories", selection: $timing) {
                        Text("When conversation ends").tag("end")
                        Text("In background").tag("background")
                    }
                    .pickerStyle(.inline)
                }
            }
        }
        .navigationTitle("Memory")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
