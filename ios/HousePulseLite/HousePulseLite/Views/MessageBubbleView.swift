import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // Message bubble
                Text(message.content)
                    .padding(12)
                    .background(message.isUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)
                    .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)

                // Tool events (if any)
                if let toolEvents = message.toolEvents, !toolEvents.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(toolEvents) { event in
                            HStack(spacing: 6) {
                                Image(systemName: event.status == "success" ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(event.status == "success" ? .green : .red)

                                Text(event.tool)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }

                // Timestamp
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }

            if !message.isUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Typing Indicator

struct TypingIndicatorView: View {
    @State private var animating = false

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .opacity(animating ? 0.3 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animating
                        )
                }
            }
            .padding(12)
            .background(Color(.systemGray5))
            .cornerRadius(16)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .onAppear {
            animating = true
        }
    }
}
