import SwiftUI

struct MessageBubble: View {
    let message: Message

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        isUser ? Color.blue : Color(.systemGray5),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .foregroundStyle(isUser ? .white : .primary)

                // Tool use indicator
                if let toolCalls = message.toolCalls, !toolCalls.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "wrench.and.screwdriver")
                            .font(.caption2)
                        Text(toolCalls.map(\.name).joined(separator: ", "))
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                }
            }

            if !isUser { Spacer(minLength: 60) }
        }
    }
}
