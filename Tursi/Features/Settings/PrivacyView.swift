import SwiftUI
import TursiCore

struct PrivacyView: View {
    @State private var showRecoveryKey = false
    @State private var recoveryKey: String?

    private let keyManager = KeyManager()

    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("End-to-End Encrypted")
                            .font(.body)
                            .fontWeight(.medium)
                        Text("Your memories are encrypted on-device before syncing. The server never sees your data.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Recovery Key") {
                Text("If you lose access to all your devices, you'll need this key to recover your memories.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    generateAndShowRecoveryKey()
                } label: {
                    Label("Show Recovery Key", systemImage: "key")
                }

                if showRecoveryKey, let key = recoveryKey {
                    Text(key)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
            }

            Section("What stays on your device") {
                InfoRow(icon: "brain", title: "AI Processing", detail: "All AI runs locally on your device")
                InfoRow(icon: "text.bubble", title: "Conversations", detail: "Stored locally in encrypted database")
                InfoRow(icon: "lightbulb", title: "Memories", detail: "Encrypted before syncing to cloud")
            }

            Section("What the cloud sees") {
                InfoRow(icon: "lock", title: "Encrypted blobs", detail: "Unreadable without your device key")
                InfoRow(icon: "person", title: "Account info", detail: "Email and sign-in method only")
            }
        }
        .navigationTitle("Privacy")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func generateAndShowRecoveryKey() {
        do {
            let key = try keyManager.getOrCreateMasterKey()
            recoveryKey = keyManager.generateRecoveryKey(from: key)
            showRecoveryKey = true
        } catch {
            // TODO: Show error
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
