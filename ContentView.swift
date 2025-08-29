import SwiftUI
import Combine

// MARK: - SwasthyaAIApp.swift (Main App Entry Point)
/*
 This is the main entry point for the application. It now contains the primary
 navigation logic to route users based on their authentication and onboarding status.
*/
@main
struct SwasthyaAIApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - MainView.swift (Root Navigation)
struct MainView: View {
    // These @AppStorage properties automatically read from UserDefaults and update the view.
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("isOnboarded") var isOnboarded: Bool = false

    var body: some View {
        // This logic determines the very first screen the user sees.
        if !isLoggedIn {
            // Always start with login page
            LoginView(isLoggedIn: $isLoggedIn)
        } else if !isOnboarded {
            OnboardingView(isOnboarded: $isOnboarded) // If logged in but not onboarded, show onboarding.
        } else {
            DashboardView() // If logged in and onboarded, go to the main dashboard.
        }
    }
}


// MARK: - Authentication/Registration Views

// MARK: - RegistrationView.swift
struct RegistrationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Binding var isPresented: Bool
    
    // Simple local storage for demo purposes
    @AppStorage("userCredentials") private var userCredentialsData: Data?

    var body: some View {
        ZStack {
            BackgroundGradientView()
            VStack(spacing: 20) {
                LogoView()
                
                VStack(spacing: 20) {
                    Text("Create Your Account")
                        .font(.title2).bold().foregroundColor(.accentTeal)
                    
                    TextField("Email Address", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    if password != confirmPassword && !confirmPassword.isEmpty {
                        Text("Passwords do not match.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button(action: registerUser) {
                        Text("Register")
                            .fontWeight(.bold)
                            .foregroundColor(.darkBlue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [.accentTeal, .accentTealLight]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                    }
                    .disabled(email.isEmpty || password.isEmpty || password != confirmPassword)
                    .opacity(email.isEmpty || password.isEmpty || password != confirmPassword ? 0.6 : 1.0)
                }
                .padding(30)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal)

                Button("Already have an account? Login") {
                    isPresented = false
                }
                .foregroundColor(.accentTeal)
            }
        }
    }
    
    private func registerUser() {
        // In a real app, hash the password. For now, store plaintext for demo.
        let credentials = ["email": email, "password": password]
        if let data = try? JSONEncoder().encode(credentials) {
            userCredentialsData = data
            isPresented = false // Close registration sheet
        }
    }
}


// MARK: - LoginView.swift
struct LoginView: View {
    // Pre-populated credentials for demo purposes
    @State private var email = "sujal"
    @State private var password = "horserun"
    @State private var showingRegistration = false
    @State private var showErrorAlert = false
    
    // This binding is now passed from MainView to control the navigation flow directly.
    @Binding var isLoggedIn: Bool
    
    @AppStorage("userCredentials") private var userCredentialsData: Data?

    var body: some View {
        ZStack {
            BackgroundGradientView()
            VStack {
                LogoView().padding(.bottom, 40)
                
                VStack(spacing: 20) {
                    Text("Secure Portal Login")
                        .font(.title2).bold().foregroundColor(.accentTeal)
                    
                    TextField("Email Address", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    Button(action: loginUser) {
                        Text("Login")
                            .fontWeight(.bold)
                            .foregroundColor(.darkBlue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [.accentTeal, .accentTealLight]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                    .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                }
                .padding(30)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal)
                
                Button("Don't have an account? Register") {
                    showingRegistration = true
                }
                .foregroundColor(.accentTeal)
                .padding(.top)
            }
        }
        .sheet(isPresented: $showingRegistration) {
            RegistrationView(isPresented: $showingRegistration)
        }
        .alert("Login Failed", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Invalid email or password. Please try again or register.")
        }
    }
    
    private func loginUser() {
        // Only allow login with exact credentials "sujal" and "horserun"
        if email == "sujal" && password == "horserun" {
            // Directly update the binding, which will cause MainView to re-render.
            self.isLoggedIn = true
        } else {
            showErrorAlert = true
        }
    }
}


// MARK: - OnboardingView.swift
struct OnboardingView: View {
    @Binding var isOnboarded: Bool
    @State private var displayName: String = ""
    @State private var selectedRole: UserRole = .unselected
    @State private var showAlert = false
    
    enum UserRole: String, CaseIterable, Identifiable {
        case unselected = "Select your role..."
        case doctor = "Doctor / Clinician"
        case patient = "Patient"
        var id: String { self.rawValue }
    }

    var body: some View {
        ZStack {
            BackgroundGradientView()
            VStack(spacing: 30) {
                LogoView()
                VStack(alignment: .leading, spacing: 25) {
                    VStack(spacing: 10) {
                        Text("Welcome to Swasthya AI")
                            .font(.title).fontWeight(.bold).foregroundColor(.accentTeal)
                        Text("Let's set up your profile to personalize your experience.")
                            .font(.subheadline).foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center).padding(.horizontal)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name").foregroundColor(.accentTeal).fontWeight(.semibold)
                        TextField("e.g., Dr. Anjali Sharma", text: $displayName).textFieldStyle(CustomTextFieldStyle())
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What is your role?").foregroundColor(.accentTeal).fontWeight(.semibold)
                        Picker("Select your role", selection: $selectedRole) {
                            ForEach(UserRole.allCases) { role in Text(role.rawValue).tag(role) }
                        }
                        .pickerStyle(MenuPickerStyle()).accentColor(.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading).padding()
                        .background(Color.black.opacity(0.2)).cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.accentTeal.opacity(0.3), lineWidth: 1))
                    }
                    Button(action: completeOnboarding) {
                        Text("Complete Setup").fontWeight(.bold).foregroundColor(.darkBlue)
                            .frame(maxWidth: .infinity).padding()
                            .background(LinearGradient(gradient: Gradient(colors: [.accentTeal, .accentTealLight]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10).shadow(color: .accentTeal.opacity(0.4), radius: 10, y: 5)
                    }
                    .disabled(displayName.isEmpty || selectedRole == .unselected)
                    .opacity((displayName.isEmpty || selectedRole == .unselected) ? 0.6 : 1.0)
                }
                .padding(30).background(.ultraThinMaterial).cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.accentTeal.opacity(0.2), lineWidth: 1))
                .padding(.horizontal)
            }
        }
        .alert("Profile Saved!", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                // After completing onboarding, mark as onboarded
                self.isOnboarded = true
            }
        } message: { Text("Welcome, \(displayName)! Your profile is ready.") }
    }
    
    private func completeOnboarding() {
        let userProfile: [String: String] = ["name": displayName, "role": selectedRole.rawValue]
        UserDefaults.standard.set(userProfile, forKey: "swasthyaAiUserProfile")
        showAlert = true
    }
}


// MARK: - Dashboard & Core Feature Views

// MARK: - DashboardView.swift
struct DashboardView: View {
    @State private var userRole: OnboardingView.UserRole = .patient
    @AppStorage("displayName") private var displayName: String = "User"

    var body: some View {
        Group {
            if userRole == .doctor {
                DoctorDashboardView(displayName: displayName)
            } else {
                PatientDashboardView(displayName: displayName)
            }
        }
        .onAppear(perform: loadUserProfile)
    }
    
    private func loadUserProfile() {
        if let profile = UserDefaults.standard.dictionary(forKey: "swasthyaAiUserProfile") as? [String: String] {
            self.displayName = profile["name"] ?? "User"
            if let roleString = profile["role"], let role = OnboardingView.UserRole(rawValue: roleString) {
                self.userRole = role
            }
        }
    }
}


// MARK: - DoctorDashboardView.swift
struct DoctorDashboardView: View {
    let displayName: String
    @State private var showingChat = false
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundGradientView()
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        Text("Welcome, \(displayName)")
                            .font(.largeTitle).bold().foregroundColor(.textPrimary)
                        
                        Text("Your Clinical Overview")
                            .font(.title2).foregroundColor(.textSecondary)
                            .padding(.bottom)

                        DashboardCard(icon: "person.2.fill", title: "Upcoming Appointments", value: "5", color: .accentTeal)
                        DashboardCard(icon: "bell.fill", title: "Pending Lab Results", value: "12", color: .orange)
                        DashboardCard(icon: "chart.bar.xaxis", title: "Analytics Overview", value: "View Stats", color: .purple)
                        DashboardCard(icon: "message.fill", title: "Unread Messages", value: "3", color: .blue)
                        
                        // AI Assistant Button
                        Button(action: { showingChat = true }) {
                            HStack {
                                Image(systemName: "sparkle.magnifyingglass")
                                    .font(.title)
                                    .foregroundColor(.darkBlue)
                                VStack(alignment: .leading) {
                                    Text("AI Assistant")
                                        .font(.headline)
                                        .foregroundColor(.darkBlue)
                                    Text("Get medical insights")
                                        .font(.subheadline)
                                        .foregroundColor(.darkBlue.opacity(0.7))
                                }
                                Spacer()
                            }
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [.accentTeal, .accentTealLight]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(15)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Clinician Dashboard")
                .navigationBarHidden(true)
            }
        }
        .sheet(isPresented: $showingChat) {
            ChatView()
        }
    }
}


// MARK: - PatientDashboardView.swift
struct PatientDashboardView: View {
    let displayName: String
    @State private var showingChat = false
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundGradientView()
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        Text("Welcome, \(displayName)")
                            .font(.largeTitle).bold().foregroundColor(.textPrimary)
                        
                        Text("Your Health Portal")
                            .font(.title2).foregroundColor(.textSecondary)
                            .padding(.bottom)

                        DashboardCard(icon: "calendar", title: "Next Appointment", value: "Sept 5, 10:00 AM", color: .accentTeal)
                        DashboardCard(icon: "doc.text.fill", title: "Latest Lab Results", value: "View Now", color: .blue)
                        DashboardCard(icon: "heart.fill", title: "My Health Records", value: "Access", color: .pink)
                        
                        // AI Assistant Button
                        Button(action: { showingChat = true }) {
                            HStack {
                                Image(systemName: "sparkle.magnifyingglass")
                                    .font(.title)
                                    .foregroundColor(.darkBlue)
                                VStack(alignment: .leading) {
                                    Text("AI Health Assistant")
                                        .font(.headline)
                                        .foregroundColor(.darkBlue)
                                    Text("Ask about your symptoms")
                                        .font(.subheadline)
                                        .foregroundColor(.darkBlue.opacity(0.7))
                                }
                                Spacer()
                            }
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [.accentTeal, .accentTealLight]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(15)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Patient Dashboard")
                .navigationBarHidden(true)
            }
        }
        .sheet(isPresented: $showingChat) {
            ChatView()
        }
    }
}


// MARK: - ChatView.swift (For Patient Dashboard)
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundGradientView()
                VStack {
                    // Conversation History
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(viewModel.messages) { message in
                                    MessageView(message: message)
                                }
                                if viewModel.isTyping {
                                    MessageView(message: Message(text: "Typing...", isFromUser: false, type: .typing))
                                }
                            }
                            .padding()
                        }
                        .onChange(of: viewModel.messages.count) {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                    
                    // Message Input Field
                    HStack {
                        TextField("Describe your symptoms...", text: $viewModel.currentMessage)
                            .textFieldStyle(CustomTextFieldStyle())
                        
                        Button(action: viewModel.sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                                .foregroundColor(.accentTeal)
                        }
                        .disabled(viewModel.currentMessage.isEmpty || viewModel.isTyping)
                    }
                    .padding()
                }
                .navigationTitle("AI Health Assistant")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

// MARK: - Chat Components, ViewModel & API Service

// Data Models for API Communication
struct APIRequest: Codable {
    let model: String
    let messages: [APIMessage]
}

struct APIMessage: Codable {
    let role: String
    let content: String
}

struct APIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: APIMessage
}

// Message model for the UI
struct Message: Identifiable, Equatable {
    enum MessageType {
        case text
        case typing
    }
    let id = UUID()
    let text: String
    let isFromUser: Bool
    var type: MessageType = .text
}

struct MessageView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }
            
            VStack(alignment: .leading) {
                if message.type == .typing {
                    TypingIndicatorView()
                } else {
                    // ✅ FIXED: Custom formatted text instead of raw Markdown
                    FormattedResponseView(text: message.text)
                        .padding(12)
                        .background(message.isFromUser ? Color.accentTeal : Color.mediumBlue)
                        .foregroundColor(message.isFromUser ? .darkBlue : .textPrimary)
                        .cornerRadius(16)
                        .textSelection(.enabled)
                }
            }
            
            if !message.isFromUser { Spacer() }
        }
    }
}

// NEW: Custom formatted response view that converts markdown-like text to proper SwiftUI formatting
struct FormattedResponseView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(parseFormattedText(), id: \.self) { section in
                formatSection(section)
            }
        }
    }
    
    private func parseFormattedText() -> [String] {
        // Split text into sections while preserving structure
        var sections = text.components(separatedBy: "\n\n")
        sections = sections.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return sections
    }
    
    @ViewBuilder
    private func formatSection(_ section: String) -> some View {
        let cleanSection = section.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanSection.hasPrefix("## ") {
            // Section headers (remove ## and make bold with icon)
            let headerText = cleanSection.replacingOccurrences(of: "## ", with: "")
            HStack(alignment: .top, spacing: 6) {
                if let emoji = extractEmoji(from: headerText) {
                    Text(emoji)
                        .font(.title3)
                }
                Text(cleanHeaderText(headerText))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.accentTeal)
                Spacer()
            }
            .padding(.vertical, 4)
            
        } else if cleanSection.contains("*") && !cleanSection.hasPrefix("_") {
            // Bullet points (convert * to •)
            VStack(alignment: .leading, spacing: 4) {
                ForEach(cleanSection.components(separatedBy: "\n"), id: \.self) { line in
                    if line.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("*") {
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(.accentTeal)
                                .fontWeight(.bold)
                            Text(line.replacingOccurrences(of: "*", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                    } else if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(line.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
            }
            
        } else if cleanSection.contains(". ") && cleanSection.first?.isNumber == true {
            // Numbered lists
            VStack(alignment: .leading, spacing: 4) {
                ForEach(cleanSection.components(separatedBy: "\n"), id: \.self) { line in
                    if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            if let firstChar = line.trimmingCharacters(in: .whitespacesAndNewlines).first,
                               firstChar.isNumber {
                                Text(String(firstChar) + ".")
                                    .foregroundColor(.accentTeal)
                                    .fontWeight(.bold)
                                Text(String(line.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines))
                                    .fixedSize(horizontal: false, vertical: true)
                            } else {
                                Text(line.trimmingCharacters(in: .whitespacesAndNewlines))
                            }
                            Spacer()
                        }
                    }
                }
            }
            
        } else if cleanSection.hasPrefix("**") && cleanSection.hasSuffix("**") {
            // Bold disclaimer
            Text(cleanSection.replacingOccurrences(of: "**", with: ""))
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .padding(.vertical, 4)
                
        } else if cleanSection.hasPrefix("_") && cleanSection.hasSuffix("_") {
            // Italic disclaimer
            Text(cleanSection.replacingOccurrences(of: "_", with: ""))
                .italic()
                .foregroundColor(.textSecondary)
                .font(.caption)
                .padding(.vertical, 2)
                
        } else {
            // Regular paragraph text
            Text(cleanSection)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func extractEmoji(from text: String) -> String? {
        let emojiPattern = "^[🩺🔬✅⚠️📋💊🏥]+"
        if let range = text.range(of: emojiPattern, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }
    
    private func cleanHeaderText(_ text: String) -> String {
        return text.replacingOccurrences(of: "^[🩺🔬✅⚠️📋💊🏥]+\\s*", with: "", options: .regularExpression)
    }
}

struct TypingIndicatorView: View {
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.textSecondary)
                    .scaleEffect(scale)
                    .animation(Animation.easeInOut(duration: 0.6).repeatForever().delay(Double(i) * 0.2), value: scale)
            }
        }
        .padding(12)
        .background(Color.mediumBlue)
        .cornerRadius(16)
        .onAppear {
            self.scale = 1.0
        }
    }
}

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = [Message(text: "Hello! I am your AI Health Assistant. How can I help you today?", isFromUser: false)]
    @Published var currentMessage: String = ""
    @Published var isTyping = false
    
    private let chatbotService = ChatbotService()
    
    func sendMessage() {
        guard !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = Message(text: currentMessage, isFromUser: true)
        messages.append(userMessage)
        let messageToSend = currentMessage
        currentMessage = ""
        isTyping = true
        
        Task {
            let response = await chatbotService.getBotResponse(for: messageToSend, history: messages)
            isTyping = false
            let botMessage = Message(text: response, isFromUser: false)
            messages.append(botMessage)
        }
    }
}

// ✅ FIXED: Updated system prompt to generate cleaner structured responses
struct ChatbotService {
    private let apiKey = "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"
    private let apiUrl = URL(string: "https://openrouter.ai/api/v1/chat/completions")!

    func getBotResponse(for message: String, history: [Message]) async -> String {
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // ✅ FIXED: Updated system prompt for clean formatting
        let systemPrompt = """
        You are 'Swasthya AI,' an expert AI medical assistant for users in Nepal. Provide clear, safe, and well-structured health information using the EXACT format below.

        When a user describes symptoms, structure your response EXACTLY like this:

        ## 🩺 Clinical Assessment
        A brief, empathetic summary of the user's symptoms in 1-2 sentences.

        ## 🔬 Possible Causes
        * This could be related to common condition A
        * May indicate condition B or similar issues
        * Sometimes caused by lifestyle factor C

        ## ✅ Recommendations
        1. Get adequate rest and stay hydrated
        2. Apply gentle heat or cold as appropriate
        3. Monitor symptoms over the next 24-48 hours
        4. Consider over-the-counter remedies if suitable

        ## ⚠️ When to See a Doctor
        * If symptoms worsen or persist beyond X days
        * If you experience severe symptoms like Y or Z
        * If you have underlying conditions that may complicate treatment

        **Disclaimer:**
        _I am an AI assistant, not a medical professional. This information is for educational purposes only. Please consult a licensed doctor for any medical advice or diagnosis._

        CRITICAL FORMATTING RULES:
        - Use ## for section headers with emojis
        - Use * for bullet points (NOT - or •)
        - Use numbers 1. 2. 3. for ordered lists
        - Use **text** for bold important warnings
        - Use _text_ for italic disclaimers
        - NEVER diagnose - always use phrases like "could be" or "may indicate"
        - Keep sections concise and readable
        - The disclaimer is MANDATORY at the end
        """
        
        let systemMessage = APIMessage(role: "system", content: systemPrompt)
        
        // Convert UI messages to API format
        var apiMessages = history.filter { $0.type == .text }.map { APIMessage(role: $0.isFromUser ? "user" : "assistant", content: $0.text) }
        apiMessages.insert(systemMessage, at: 0)
        apiMessages.append(APIMessage(role: "user", content: message))
        
        let requestBody = APIRequest(model: "deepseek/deepseek-r1:free", messages: apiMessages)
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            return decodedResponse.choices.first?.message.content ?? "Sorry, I couldn't process that. Please try again."
        } catch {
            print("API Error: \(error.localizedDescription)")
            return "Sorry, I'm having trouble connecting right now. Please check your connection and try again."
        }
    }
}


// MARK: - Reusable UI Components & Helpers
struct BackgroundGradientView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.darkBlue, Color.mediumBlue]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
    }
}

struct LogoView: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("Swasthya").font(.largeTitle).fontWeight(.bold).foregroundColor(.textPrimary)
            Text("AI").font(.largeTitle).fontWeight(.bold).foregroundColor(.accentTeal)
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration.padding().background(Color.black.opacity(0.2)).cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.accentTeal.opacity(0.3), lineWidth: 1))
            .foregroundColor(.textPrimary).accentColor(.accentTeal)
    }
}

struct DashboardCard: View {
    let icon: String, title: String, value: String, color: Color
    var body: some View {
        HStack {
            Image(systemName: icon).font(.title).foregroundColor(color).frame(width: 50)
            VStack(alignment: .leading) {
                Text(title).font(.headline).foregroundColor(.textSecondary)
                Text(value).font(.title2).fontWeight(.bold).foregroundColor(.textPrimary)
            }
            Spacer()
        }
        .padding().background(.ultraThinMaterial).cornerRadius(15)
    }
}

// MARK: - Color Extensions
extension Color {
    static let darkBlue = Color(red: 10/255, green: 29/255, blue: 55/255)
    static let mediumBlue = Color(red: 30/255, green: 58/255, blue: 95/255)
    static let accentTeal = Color(red: 0/255, green: 198/255, blue: 167/255)
    static let accentTealLight = Color(red: 80/255, green: 227/255, blue: 194/255)
    static let textPrimary = Color(red: 230/255, green: 241/255, blue: 255/255)
    static let textSecondary = Color(red: 168/255, green: 178/255, blue: 209/255)
}

// MARK: - Previews
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))
    }
}
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View { OnboardingView(isOnboarded: .constant(false)) }
}
struct DoctorDashboardView_Previews: PreviewProvider {
    static var previews: some View { DoctorDashboardView(displayName: "Dr. Sujal") }
}
struct PatientDashboardView_Previews: PreviewProvider {
    static var previews: some View { PatientDashboardView(displayName: "Sujal") }
}
struct ChatView_Previews: PreviewProvider {
    static var previews: some View { ChatView() }
}
