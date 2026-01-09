import SwiftUI

struct ChatView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var chatViewModel: ChatViewModel
    @State private var showQuickActions = true
    @State private var showPrivacy = false

    init(homeId: String) {
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(homeId: homeId))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 8) {
                            // Welcome message (if no messages)
                            if chatViewModel.messages.isEmpty {
                                WelcomeView()
                                    .padding()
                            }

                            // Messages
                            ForEach(chatViewModel.messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }

                            // Typing indicator
                            if chatViewModel.isLoading {
                                TypingIndicatorView()
                                    .id("typing")
                            }

                            // Rate limit hint
                            if chatViewModel.showRateLimitHint {
                                RateLimitHintView()
                                    .padding()
                                    .transition(.scale.combined(with: .opacity))
                            }

                            // Error message
                            if let errorMessage = chatViewModel.errorMessage,
                               !chatViewModel.showRateLimitHint {
                                ErrorMessageView(message: errorMessage) {
                                    chatViewModel.clearError()
                                }
                                .padding()
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .onChange(of: chatViewModel.messages.count) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: chatViewModel.isLoading) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                }

                Divider()

                // Quick action chips (collapsible)
                if showQuickActions && chatViewModel.messages.isEmpty {
                    QuickActionsView(chatViewModel: chatViewModel)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Input area
                MessageInputView(chatViewModel: chatViewModel)
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        Image(systemName: "eye.slash.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Read-Only")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Text(chatViewModel.usageText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        Button(action: {
                            showPrivacy = true
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .animation(.default, value: showQuickActions)
        .sheet(isPresented: $showPrivacy) {
            PrivacyView()
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                if chatViewModel.isLoading {
                    proxy.scrollTo("typing", anchor: .bottom)
                } else if let lastMessage = chatViewModel.messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
}

// MARK: - Welcome View

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Willkommen bei HousePulse")
                .font(.title2)
                .fontWeight(.bold)

            Text("Stellen Sie Fragen zu Ihrem Smart Home oder wählen Sie eine Schnellaktion unten.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Quick Actions View

struct QuickActionsView: View {
    @ObservedObject var chatViewModel: ChatViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Schnellaktionen")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(QuickAction.allCases, id: \.self) { action in
                        QuickActionChip(action: action) {
                            Task {
                                await chatViewModel.sendQuickAction(action)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }
}

struct QuickActionChip: View {
    let action: QuickAction
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: action.icon)
                    .font(.caption)
                Text(action.rawValue)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(20)
        }
    }
}

// MARK: - Message Input View

struct MessageInputView: View {
    @ObservedObject var chatViewModel: ChatViewModel

    var body: some View {
        HStack(spacing: 12) {
            TextField("Nachricht eingeben...", text: $chatViewModel.currentInput, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .lineLimit(1...5)
                .disabled(chatViewModel.isLoading)

            Button(action: {
                Task {
                    await chatViewModel.sendMessage()
                }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(chatViewModel.currentInput.isEmpty || chatViewModel.isLoading ? .gray : .blue)
            }
            .disabled(chatViewModel.currentInput.isEmpty || chatViewModel.isLoading)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Rate Limit Hint View

struct RateLimitHintView: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Tageslimit erreicht")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Sie haben das Tageslimit von 50 Nachrichten erreicht.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)

            Text("💡 Tipp: Upgrade für unbegrenzte Nachrichten")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Error Message View

struct ErrorMessageView: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}
