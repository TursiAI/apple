import SwiftUI

struct ModelSettingsView: View {
    @AppStorage("selectedModel") private var selectedModel = "standard"
    @State private var downloadProgress: Double?
    @State private var isDownloading = false

    var body: some View {
        Form {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Standard")
                            .font(.body)
                        Text("Built-in Apple AI. No download required.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if selectedModel == "standard" {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { selectedModel = "standard" }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enhanced")
                            .font(.body)
                        Text("More detailed responses and better memory recall. ~1.8 GB download.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if selectedModel == "enhanced" {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                    } else if isDownloading {
                        ProgressView(value: downloadProgress)
                            .frame(width: 60)
                    } else {
                        Button("Download") {
                            startDownload()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // Only select if downloaded
                    // TODO: Check if model is downloaded
                }
            } header: {
                Text("AI Model")
            } footer: {
                Text("All AI processing happens on your device. Nothing is sent to external servers.")
            }
        }
        .navigationTitle("AI Model")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func startDownload() {
        isDownloading = true
        downloadProgress = 0
        // TODO: Actually download via MLXEngine
    }
}
