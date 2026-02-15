import SwiftUI

struct MessagesSection: View {
    @ObservedObject var viewModel: MessagesViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardHeader(
                title: "Messages",
                subtitle: "Chat with customers in real time",
                icon: "message.fill",
                gradient: DashboardTheme.headerGradient
            )

            Group {
                if sizeClass == .compact {
                    VStack(spacing: 16) {
                        conversationList
                        chatThread
                    }
                } else {
                    HStack(alignment: .top, spacing: 16) {
                        conversationList
                            .frame(width: 280)
                        chatThread
                    }
                }
            }
        }
        .dashboardCard()
    }

    private var conversationList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet")
                    .font(.app(14, weight: .semibold))
                Text("Conversations")
                    .font(.app(13, weight: .semibold))
            }
            .foregroundStyle(DashboardTheme.text)

            ScrollView {
                LazyVStack(spacing: 8) {
                    if viewModel.conversations.isEmpty {
                        Text("No conversations yet.")
                            .font(.app(12, weight: .medium))
                            .foregroundStyle(DashboardTheme.textMuted)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 16)
                    } else {
                        ForEach(viewModel.conversations) { conversation in
                            Button {
                                viewModel.selectConversation(conversation.userId)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(viewModel.label(for: conversation.userId))
                                        .font(.app(13, weight: .semibold))
                                        .foregroundStyle(DashboardTheme.text)
                                    Text(conversation.lastText)
                                        .font(.app(12, weight: .medium))
                                        .foregroundStyle(DashboardTheme.textMuted)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectionColor(for: conversation.userId))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(borderColor(for: conversation.userId), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(12)
        .background(DashboardTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DashboardTheme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var chatThread: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.selectedUserId.map(viewModel.label) ?? "Select a user")
                        .font(.app(14, weight: .semibold))
                        .foregroundStyle(DashboardTheme.text)
                    Text(viewModel.selectedUserId == nil ? "Waiting for conversation" : "Active conversation")
                        .font(.app(12, weight: .medium))
                        .foregroundStyle(DashboardTheme.textMuted)
                }
                Spacer()
                Button("Refresh") {
                    Task { await viewModel.loadProfiles() }
                }
                .font(.app(12, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(DashboardTheme.background)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(DashboardTheme.border, lineWidth: 1))
            }
            .padding(12)
            .background(DashboardTheme.card)

            Divider()
                .overlay(DashboardTheme.border)

            if viewModel.selectedUserId == nil {
                Text("Choose a conversation to start chatting.")
                    .font(.app(12, weight: .medium))
                    .foregroundStyle(DashboardTheme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
                    .background(DashboardTheme.background)
            } else {
                ChatMessagesView(messages: viewModel.messages)
                    .frame(maxWidth: .infinity)
            }

            Divider()
                .overlay(DashboardTheme.border)

            HStack(spacing: 8) {
                TextField("Type a message...", text: $viewModel.messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.app(12, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(DashboardTheme.surface)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(DashboardTheme.border, lineWidth: 1))
                    .disabled(viewModel.selectedUserId == nil)
                    .focused($isInputFocused)
                    .onSubmit { Task { await viewModel.sendMessage() } }

                Button {
                    Task { await viewModel.sendMessage() }
                } label: {
                    Text("Send")
                        .font(.app(12, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .foregroundStyle(.white)
                        .background(DashboardTheme.headerGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(viewModel.selectedUserId == nil)
                .opacity(viewModel.selectedUserId == nil ? 0.6 : 1)
            }
            .padding(12)
            .background(DashboardTheme.card)
        }
        .background(DashboardTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DashboardTheme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture {
            isInputFocused = false
        }
    }

    private func selectionColor(for userId: String) -> Color {
        if viewModel.selectedUserId == userId {
            return DashboardTheme.primary.opacity(0.12)
        }
        return DashboardTheme.surface
    }

    private func borderColor(for userId: String) -> Color {
        if viewModel.selectedUserId == userId {
            return DashboardTheme.primary
        }
        return DashboardTheme.border
    }
}

private struct ChatMessagesView: View {
    let messages: [ChatMessage]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    if messages.isEmpty {
                        Text("No messages yet.")
                            .font(.app(12, weight: .medium))
                            .foregroundStyle(DashboardTheme.textMuted)
                            .padding(.vertical, 24)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(messages) { message in
                            HStack {
                                if message.isFromAdmin {
                                    Spacer(minLength: 40)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(message.text)
                                        .font(.app(12, weight: .medium))
                                        .foregroundStyle(message.isFromAdmin ? Color.white : DashboardTheme.text)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    message.isFromAdmin
                                    ? AnyShapeStyle(DashboardTheme.headerGradient)
                                    : AnyShapeStyle(DashboardTheme.card)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                if !message.isFromAdmin {
                                    Spacer(minLength: 40)
                                }
                            }
                            .id(message.id)
                        }
                    }
                }
                .padding(12)
            }
            .background(DashboardTheme.background)
            .onChange(of: messages) { _ in
                if let last = messages.last {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}
