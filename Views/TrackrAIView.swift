//
//  TrackrAIView.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 18/07/25.
//

import SwiftUI

struct TrackrAIView: View {
    
    @StateObject private var aiService = TrackrAIService()
    @State private var messageText = ""
    @State private var showSidebar = false
    @State private var recentSearches: [RecentSearch] = []
    @FocusState private var isTextFieldFocused: Bool
    @State private var showClearAlert = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Restore the background gradient
            AppGradients.primaryButton
                .ignoresSafeArea(.all)
            
            // Main Chat View (always full width)
            mainChatView
            
            // Sidebar Overlay
            if showSidebar {
                HStack(spacing: 0) {
                    // Sidebar
                    sidebarView
                        .frame(width: UIScreen.main.bounds.width * 0.8)
                        .transition(.move(edge: .leading))
                    
                    // Overlay area to close sidebar
                    Color.black.opacity(0.3)
                        .onTapGesture {
                            closeSidebar()
                        }
                }
                .ignoresSafeArea(.all)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadRecentSearches()
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
        .alert("Clear Chat History", isPresented: $showClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                startNewChat()
            }
        } message: {
            Text("This will permanently delete all your chat messages. This action cannot be undone.")
        }
    }
    
    // MARK: - Keyboard Observers
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeInOut(duration: 0.3)) {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                keyboardHeight = 0
            }
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private var sidebarView: some View {
        VStack(spacing: 0) {
            // Sidebar Header with extra top padding for status bar
            VStack(spacing: 0) {
                // Status bar spacer
                Color.clear
                    .frame(height: UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .first?.windows.first?.safeAreaInsets.top ?? 44)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Trackr AI")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Crypto Assistant")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        closeSidebar()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Divider()
                    .background(Color.white.opacity(0.1))
            }
            
            // New Chat Button
            Button(action: {
                startNewChat()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    
                    Text("New Chat")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Scrollable Content with HIDDEN scroll indicators
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    if !recentSearches.isEmpty {
                        HStack {
                            Text("Recent")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 8)
                        
                        ForEach(recentSearches) { search in
                            RecentSearchRow(search: search) {
                                loadSearch(search)
                            }
                        }
                    }
                    
                    // Quick Actions Section
                    HStack {
                        Text("Quick Actions")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, recentSearches.isEmpty ? 20 : 10)
                    .padding(.bottom, 8)
                    
                    QuickActionRow(icon: "bitcoinsign.circle", title: "Bitcoin Price", subtitle: "Get current BTC price") {
                        performQuickAction("What's the current Bitcoin price?")
                    }
                    
                    QuickActionRow(icon: "chart.line.uptrend.xyaxis", title: "Market Trends", subtitle: "Crypto market analysis") {
                        performQuickAction("Show me current crypto market trends")
                    }
                    
                    QuickActionRow(icon: "newspaper", title: "Crypto News", subtitle: "Latest crypto news") {
                        performQuickAction("What's the latest cryptocurrency news?")
                    }
                    
                    QuickActionRow(icon: "graduationcap", title: "Learn Crypto", subtitle: "Crypto education") {
                        performQuickAction("Explain blockchain technology for beginners")
                    }
                    
                    QuickActionRow(icon: "film", title: "Movies", subtitle: "Movie information & reviews") {
                        performQuickAction("Telugu movies in theaters")
                    }
                    
                    QuickActionRow(icon: "cloud.sun", title: "Weather", subtitle: "Weather information") {
                        performQuickAction("Weather in Vellore")
                    }
                    
                    // Bottom padding for safe area
                    Color.clear
                        .frame(height: UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .first?.windows.first?.safeAreaInsets.bottom ?? 20)
                }
            }
            
            Spacer(minLength: 0)
        }
        .background(AppGradients.primaryButton)
        .ignoresSafeArea(.all)
    }
    
    private var mainChatView: some View {
        VStack(spacing: 0) {
            headerSection
            chatMessagesSection
            inputSection
        }
        // Improved keyboard handling - move content up more when keyboard appears
        .padding(.bottom, keyboardHeight > 0 ? keyboardHeight - 20 : 80) // Changed from -60 to -20 for better positioning
        .disabled(showSidebar)
        .onTapGesture {
            if !showSidebar {
                isTextFieldFocused = false
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button(action: {
                openSidebar()
            }) {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("Trackr AI")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                // 🗑️ TRASH/CLEAR BUTTON
                Button(action: {
                    showClearAlert = true
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    startNewChat()
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    private var chatMessagesSection: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    if aiService.messages.isEmpty {
                        welcomeMessage
                    }
                    
                    ForEach(aiService.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    
                    if aiService.isLoading {
                        TypingIndicator()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .onChange(of: aiService.messages.count) { oldValue, newValue in
                if let lastMessage = aiService.messages.last {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: keyboardHeight) { _, _ in
                // Scroll to bottom when keyboard appears/disappears
                if let lastMessage = aiService.messages.last {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
    
    private var welcomeMessage: some View {
        VStack(spacing: 20) {
            // AI Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 35))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text("Welcome to Trackr AI!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Your AI-powered assistant for cryptocurrency, movies, weather, and more. Ask me anything!")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            VStack(spacing: 12) {
                Text("Try asking:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                VStack(spacing: 8) {
                    SuggestionButton(text: "What's the current Bitcoin price?") {
                        sendMessage("What's the current Bitcoin price?")
                    }
                    
                    SuggestionButton(text: "Telugu movies in theaters") {
                        sendMessage("Telugu movies in theaters")
                    }
                    
                    SuggestionButton(text: "Tell me about Brick movie") {
                        sendMessage("Tell me about Brick movie")
                    }
                    
                    SuggestionButton(text: "Weather in Vellore") {
                        sendMessage("Weather in Vellore")
                    }
                }
            }
        }
        .padding(.top, 40)
    }
    
    private var inputSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                DynamicTextEditor(text: $messageText, placeholder: "Ask Trackr AI anything...")
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        sendMessage()
                    }
                
                if !messageText.isEmpty {
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.cyan)
                    }
                    .disabled(aiService.isLoading)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, -10)
    }
    
    // MARK: - Animation Functions
    
    private func openSidebar() {
        withAnimation(.easeOut(duration: 0.25)) {
            showSidebar = true
        }
    }
    
    private func closeSidebar() {
        withAnimation(.easeIn(duration: 0.2)) {
            showSidebar = false
        }
    }
    
    // MARK: - Functions
    
    private func sendMessage(_ text: String? = nil) {
        let message = text ?? messageText
        guard !message.isEmpty else { return }
        
        addToRecentSearches(message)
        aiService.sendMessage(message)
        messageText = ""
        isTextFieldFocused = false
        
        if showSidebar {
            closeSidebar()
        }
    }
    
    private func startNewChat() {
        aiService.clearChat()
        if showSidebar {
            closeSidebar()
        }
    }
    
    private func performQuickAction(_ message: String) {
        sendMessage(message)
    }
    
    private func loadSearch(_ search: RecentSearch) {
        sendMessage(search.query)
    }
    
    private func addToRecentSearches(_ query: String) {
        let newSearch = RecentSearch(query: query)
        
        recentSearches.removeAll { $0.query == query }
        recentSearches.insert(newSearch, at: 0)
        
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        
        saveRecentSearches()
    }
    
    private func loadRecentSearches() {
        recentSearches = [
            RecentSearch(query: "Telugu movies in theaters"),
            RecentSearch(query: "Tell me about Brick movie"),
            RecentSearch(query: "Bitcoin price analysis"),
            RecentSearch(query: "Weather in Vellore"),
            RecentSearch(query: "Latest crypto trends")
        ]
    }
    
    private func saveRecentSearches() {
        // Implement saving to UserDefaults or Core Data
    }
}

// MARK: - Supporting Views (keep all existing supporting views)

struct DynamicTextEditor: View {
    @Binding var text: String
    let placeholder: String
    @State private var textHeight: CGFloat = 20
    
    private let minHeight: CGFloat = 20
    private let maxHeight: CGFloat = 100
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 2)
            }
            
            TextEditor(text: $text)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .frame(minHeight: minHeight, maxHeight: maxHeight)
                .frame(height: max(minHeight, min(maxHeight, textHeight)))
                .onChange(of: text) { _, newValue in
                    updateTextHeight()
                }
        }
        .onAppear {
            updateTextHeight()
        }
    }
    
    private func updateTextHeight() {
        let size = text.boundingRect(
            with: CGSize(width: UIScreen.main.bounds.width - 120, height: .infinity),
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.systemFont(ofSize: 16)],
            context: nil
        )
        
        DispatchQueue.main.async {
            let newHeight = max(minHeight, size.height + 8)
            textHeight = min(maxHeight, newHeight)
        }
    }
}

struct RecentSearch: Identifiable, Codable {
    let id = UUID()
    let query: String
    let timestamp = Date()
}

struct RecentSearchRow: View {
    let search: RecentSearch
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(search.query)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(timeAgo(from: search.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct QuickActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.cyan)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MessageBubble: View {
    let message: AIMessage
    @State private var showCopied = false
    @State private var isPressed = false
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                
                Text(message.content)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.cyan)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.cyan)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                            )
                        
                        Text("Trackr AI")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Button(action: {
                            copyToClipboard()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: showCopied ? "checkmark.circle.fill" : "doc.on.doc")
                                    .font(.system(size: 12))
                                    .foregroundColor(showCopied ? .green : .white.opacity(0.7))
                                
                                if showCopied {
                                    Text("Copied!")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.horizontal, showCopied ? 8 : 6)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(showCopied ? Color.green.opacity(0.2) : Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(showCopied ? Color.green.opacity(0.4) : Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .scaleEffect(isPressed ? 0.95 : 1.0)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Text(message.content)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                }
                
                Spacer()
            }
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = message.content
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopied = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showCopied = false
            }
        }
    }
}

struct SuggestionButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
    }
}

struct TypingIndicator: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                        )
                    
                    Text("Trackr AI is thinking...")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 8, height: 8)
                            .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: animationPhase
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            
            Spacer()
        }
        .onAppear {
            animationPhase = 0
        }
    }
}

#Preview {
    TrackrAIView()
}
