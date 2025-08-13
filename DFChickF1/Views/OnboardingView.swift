//
//  OnboardingView.swift
//  LingoFusion
//
//  Created by IGOR on 08/08/2025.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ZStack {
            Color(hex: "3e4464").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                progressBar
                
                // Content
                GeometryReader { geometry in
                    TabView(selection: $viewModel.currentStep) {
                        ForEach(OnboardingViewModel.OnboardingStep.allCases, id: \.rawValue) { step in
                            onboardingStepView(for: step)
                                .tag(step)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .gesture(DragGesture().onChanged { _ in }) // Disable swipe gestures without disabling buttons
                }
                
                // Navigation buttons
                navigationButtons
            }
        }
        .animation(.easeInOut, value: viewModel.currentStep)
    }
    
    // MARK: - Computed Properties
    private var availableLanguagesForLearning: [Language] {
        LanguageService.shared.availableLanguages.filter { language in
            language.isAvailable && 
            language.code != "en" &&
            language.id != viewModel.nativeLanguage?.id
        }
    }
    
    private var progressBar: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack {
                ForEach(0..<OnboardingViewModel.OnboardingStep.allCases.count, id: \.self) { index in
                    Rectangle()
                        .fill(index <= viewModel.currentStep.rawValue ? Color(hex: "fcc418") : Color.white.opacity(0.3))
                        .frame(height: 3)
                    
                    if index < OnboardingViewModel.OnboardingStep.allCases.count - 1 {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            // Step indicator
            HStack {
                Text("Step \(viewModel.currentStep.rawValue + 1) of \(OnboardingViewModel.OnboardingStep.allCases.count)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Button("Skip") {
                    viewModel.skipOnboarding()
                }
                .font(.caption)
                .foregroundColor(Color(hex: "fcc418"))
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if viewModel.currentStep.rawValue > 0 {
                Button("Back") {
                    viewModel.previousStep()
                }
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            
            Button(viewModel.currentStep == .completed ? "Get Started" : "Continue") {
                viewModel.nextStep()
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.canProceed ? Color(hex: "fcc418") : Color.gray)
            .cornerRadius(12)
            .disabled(!viewModel.canProceed)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    @ViewBuilder
    private func onboardingStepView(for step: OnboardingViewModel.OnboardingStep) -> some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)
                
                // Header
                VStack(spacing: 16) {
                    stepIcon(for: step)
                    
                    Text(step.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(step.description)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Content based on step
                stepContent(for: step)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private func stepIcon(for step: OnboardingViewModel.OnboardingStep) -> some View {
        ZStack {
            Circle()
                .fill(Color(hex: "fcc418").opacity(0.2))
                .frame(width: 80, height: 80)
            
            Image(systemName: iconName(for: step))
                .font(.system(size: 32))
                .foregroundColor(Color(hex: "fcc418"))
        }
    }
    
    private func iconName(for step: OnboardingViewModel.OnboardingStep) -> String {
        switch step {
        case .welcome:
            return "hand.wave.fill"
        case .languageSelection:
            return "globe"
        case .difficultyLevel:
            return "chart.bar.fill"
        case .goals:
            return "target"
        case .notifications:
            return "bell.fill"
        case .permissions:
            return "checkmark.shield.fill"
        case .completed:
            return "checkmark.circle.fill"
        }
    }
    
    @ViewBuilder
    private func stepContent(for step: OnboardingViewModel.OnboardingStep) -> some View {
        switch step {
        case .welcome:
            welcomeContent
        case .languageSelection:
            languageSelectionContent
        case .difficultyLevel:
            difficultyLevelContent
        case .goals:
            goalsContent
        case .notifications:
            notificationsContent
        case .permissions:
            permissionsContent
        case .completed:
            completedContent
        }
    }
    
    private var welcomeContent: some View {
        VStack(spacing: 24) {
            // Feature highlights
            VStack(spacing: 16) {
                FeatureHighlight(
                    icon: "book.fill",
                    title: "Interactive Lessons",
                    description: "Learn through structured lessons with vocabulary and exercises"
                )
                
                FeatureHighlight(
                    icon: "gamecontroller.fill",
                    title: "Gamified Progress",
                    description: "Earn XP, unlock achievements, and maintain learning streaks"
                )
                
                FeatureHighlight(
                    icon: "heart.fill",
                    title: "Personal Vocabulary",
                    description: "Build your own custom vocabulary collection"
                )
            }
        }
    }
    
    private var languageSelectionContent: some View {
        VStack(spacing: 20) {
            // Native language selection
            VStack(alignment: .leading, spacing: 12) {
                Text("I speak:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(LanguageService.shared.availableLanguages) { language in
                            LanguageCard(
                                language: language,
                                isSelected: viewModel.nativeLanguage?.id == language.id
                            ) {
                                viewModel.setNativeLanguage(language)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // Learning languages selection
            VStack(alignment: .leading, spacing: 12) {
                Text("I want to learn:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(availableLanguagesForLearning) { language in
                        LanguageCard(
                            language: language,
                            isSelected: viewModel.selectedLanguages.contains { $0.id == language.id }
                        ) {
                            viewModel.selectLanguage(language)
                        }
                    }
                }
                
                if availableLanguagesForLearning.isEmpty {
                    Text("Please select your native language first")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
    }
    
    private var difficultyLevelContent: some View {
        VStack(spacing: 16) {
            ForEach(DifficultyLevel.allCases, id: \.rawValue) { level in
                DifficultyCard(
                    level: level,
                    isSelected: viewModel.difficultyLevel == level
                ) {
                    viewModel.setDifficultyLevel(level)
                }
            }
        }
    }
    
    private var goalsContent: some View {
        VStack(spacing: 24) {
            Text("Daily study goal: \(viewModel.dailyGoal) minutes")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                HStack {
                    Text("5 min")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("60 min")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Slider(value: Binding(
                    get: { Double(viewModel.dailyGoal) },
                    set: { viewModel.setDailyGoal(Int($0)) }
                ), in: 5...60, step: 5)
                .accentColor(Color(hex: "fcc418"))
            }
            
            // Quick goal presets
            HStack(spacing: 12) {
                ForEach([10, 15, 30, 45], id: \.self) { minutes in
                    Button("\(minutes)m") {
                        viewModel.setDailyGoal(minutes)
                    }
                    .foregroundColor(viewModel.dailyGoal == minutes ? .black : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(viewModel.dailyGoal == minutes ? Color(hex: "fcc418") : Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private var notificationsContent: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Toggle("Enable study reminders", isOn: $viewModel.notificationsEnabled)
                    .foregroundColor(.white)
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "fcc418")))
                
                if viewModel.notificationsEnabled {
                    DatePicker(
                        "Reminder time",
                        selection: $viewModel.reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .foregroundColor(.white)
                    .accentColor(Color(hex: "fcc418"))
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            
            Text("We'll send you gentle reminders to help maintain your learning streak")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
    
    private var permissionsContent: some View {
        VStack(spacing: 20) {
            PermissionCard(
                icon: "bell.fill",
                title: "Notifications",
                description: "Get reminders for your daily learning goals",
                isEnabled: false
            )
            
            Text("You can enable notifications later in Settings to help maintain your learning streak")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
    
    private var completedContent: some View {
        VStack(spacing: 24) {
            LottieAnimationView(name: "celebration")
                .frame(width: 200, height: 200)
            
            VStack(spacing: 12) {
                Text("Ready to start learning!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Your personalized learning journey begins now")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Supporting Views

struct FeatureHighlight: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "fcc418"))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct LanguageCard: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Text(language.flag)
                        .font(.system(size: 24))
                        .opacity(language.isAvailable ? 1.0 : 0.5)
                    
                    if !language.isAvailable {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .offset(x: 12, y: -8)
                    }
                }
                
                VStack(spacing: 2) {
                    Text(language.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(language.isAvailable ? .white : .white.opacity(0.5))
                        .lineLimit(1)
                    
                    if !language.isAvailable {
                        Text("Coming Soon")
                            .font(.system(size: 8))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected ? Color(hex: "fcc418").opacity(0.3) : 
                language.isAvailable ? Color.white.opacity(0.1) : Color.white.opacity(0.05)
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color(hex: "fcc418") : 
                        language.isAvailable ? Color.clear : Color.white.opacity(0.2), 
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .disabled(!language.isAvailable)
    }
}

struct DifficultyCard: View {
    let level: DifficultyLevel
    let isSelected: Bool
    let action: () -> Void
    
    private var description: String {
        switch level {
        case .beginner:
            return "New to the language"
        case .intermediate:
            return "Know some basics"
        case .advanced:
            return "Conversational level"
        }
    }
    
    private var icon: String {
        switch level {
        case .beginner:
            return "leaf.fill"
        case .intermediate:
            return "star.fill"
        case .advanced:
            return "crown.fill"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "fcc418"))
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "fcc418"))
                }
            }
            .padding()
            .background(isSelected ? Color(hex: "fcc418").opacity(0.2) : Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "fcc418") : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "fcc418"))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isEnabled ? Color(hex: "3cc45b") : .white.opacity(0.3))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Lottie Animation Placeholder
struct LottieAnimationView: View {
    let name: String
    
    var body: some View {
        // Placeholder for Lottie animation
        ZStack {
            Circle()
                .fill(Color(hex: "fcc418").opacity(0.2))
            
            Image(systemName: "party.popper.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "fcc418"))
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(OnboardingViewModel())
}