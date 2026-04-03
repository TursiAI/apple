import SwiftUI
import TursiCore

struct IntegrationsView: View {
    @State private var integrations: [Integration] = Integration.defaults
    @State private var showAddCustom = false

    var body: some View {
        List {
            Section {
                ForEach($integrations) { $integration in
                    IntegrationRow(integration: $integration)
                }
            } header: {
                Text("Available")
            } footer: {
                Text("When enabled, your AI can read and act on these services.")
            }

            Section {
                Button {
                    showAddCustom = true
                } label: {
                    Label("Add Custom MCP Server", systemImage: "plus.circle")
                }
            }
        }
        .navigationTitle("Integrations")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $showAddCustom) {
            AddCustomServerView()
        }
    }
}

// MARK: - Integration row

struct IntegrationRow: View {
    @Binding var integration: Integration

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: integration.icon)
                .font(.title3)
                .frame(width: 32)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(integration.displayName)
                    .font(.body)
                Text(integration.permissionLevel == .askEveryTime ? "Asks before acting" : "Auto-approved")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: $integration.isEnabled)
                .labelsHidden()
        }
    }
}

// MARK: - Add custom server

struct AddCustomServerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var urlString = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Server Name", text: $name)
                TextField("MCP Server URL", text: $urlString)
                    .textContentType(.URL)
                    #if os(iOS)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    #endif
            }
            .navigationTitle("Custom Server")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        // TODO: Validate URL, create integration, save
                        dismiss()
                    }
                    .disabled(name.isEmpty || urlString.isEmpty)
                }
            }
        }
    }
}

// MARK: - Default integrations

extension Integration {
    static let defaults: [Integration] = [
        Integration(id: "web-search", displayName: "Web Search", icon: "globe", mcpEndpoint: .builtIn),
        Integration(id: "gmail", displayName: "Email (Gmail)", icon: "envelope", mcpEndpoint: .remote(url: URL(string: "https://mcp.tursi.ai/gmail")!), authState: .required),
        Integration(id: "calendar", displayName: "Calendar", icon: "calendar", authState: .required),
        Integration(id: "github", displayName: "GitHub", icon: "chevron.left.forwardslash.chevron.right", authState: .required),
        Integration(id: "notes", displayName: "Notes & Files", icon: "doc.text", mcpEndpoint: .builtIn),
    ]
}
