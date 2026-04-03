import SwiftUI

struct AccountView: View {
    @State private var showDeleteConfirmation = false
    @State private var deleteText = ""

    var body: some View {
        Form {
            Section("Account") {
                LabeledContent("Status", value: "Not signed in")
                Button("Sign in with Apple") {
                    // TODO: Apple Sign-In flow
                }
            }

            Section("Sync") {
                LabeledContent("Status", value: "Not syncing")
                LabeledContent("Devices", value: "1")
            }

            Section("Data") {
                Button("Export All Data") {
                    // TODO: Export decrypted data as JSON
                }

                Button("Delete All Data", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }
        }
        .navigationTitle("Account")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .alert("Delete All Data", isPresented: $showDeleteConfirmation) {
            TextField("Type DELETE to confirm", text: $deleteText)
            Button("Cancel", role: .cancel) { deleteText = "" }
            Button("Delete Everything", role: .destructive) {
                // TODO: Wipe local DB, remote data, keys
                deleteText = ""
            }
            .disabled(deleteText != "DELETE")
        } message: {
            Text("This will permanently delete all conversations, memories, and account data. This cannot be undone.")
        }
    }
}
