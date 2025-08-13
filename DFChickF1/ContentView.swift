//
//  ContentView.swift
//  LingoFusion
//
//  Created by IGOR on 08/08/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "onboardingCompleted")
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView()
                    .environmentObject(onboardingViewModel)
            } else {
                MainTabView()
            }
        }
        .preferredColorScheme(.dark)
        .onReceive(onboardingViewModel.$isCompleted) { isCompleted in
            if isCompleted {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showOnboarding = false
                }
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Learning Module Tab
            LearningModuleView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Learn")
                }
                .tag(0)
            
            // Progress Tab
            UserProgressView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Progress")
                }
                .tag(1)
            
            // Vocabulary Tab
            VocabularyLearningView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Vocabulary")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(Color(hex: "fcc418"))
        .preferredColorScheme(.dark)
    }
}

// MARK: - Vocabulary Learning View
struct VocabularyLearningView: View {
    @StateObject private var languageService = LanguageService.shared
    @State private var showingAddWord = false
    @State private var selectedLanguage = "it" // Default to Italian
    @State private var editingVocabulary: UserVocabulary?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("My Vocabulary")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                        .foregroundColor(.white)
                                
                                Text("Add and manage your personal word collection")
                                    .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            }
                    
                    Spacer()
                    
                    Button(action: {
                                showingAddWord = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Color(hex: "3cc45b"))
                            }
                    }
                    .padding(.horizontal, 20)
                        .padding(.top, 60)
                        
                        // Language filter
                        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                                ForEach(languageService.availableLanguages.filter { $0.code != "en" && $0.isAvailable }) { language in
                    Button(action: {
                                        selectedLanguage = language.code
                                    }) {
                                        HStack(spacing: 8) {
                                            Text(language.flag)
                                            Text(language.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(selectedLanguage == language.code ? .black : .white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedLanguage == language.code ? Color(hex: "fcc418") : Color.white.opacity(0.2))
                                        .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .background(Color(hex: "3e4464"))
                    
                    // Vocabulary list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            let filteredVocabulary = languageService.userVocabulary.filter { $0.language == selectedLanguage }
                            
                            if filteredVocabulary.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.3))
                    
                                    Text("No words yet")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text("Tap the + button to add your first word")
                                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                                .padding(.top, 100)
            } else {
                                ForEach(filteredVocabulary.sorted { $0.dateAdded > $1.dateAdded }) { vocabulary in
                                    UserVocabularyCard(vocabulary: vocabulary) {
                                        editingVocabulary = vocabulary
                                    } onDelete: {
                                        languageService.removeUserVocabulary(vocabulary.id)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            }
            .sheet(isPresented: $showingAddWord) {
            AddVocabularyView(selectedLanguage: selectedLanguage)
        }
        .sheet(item: $editingVocabulary) { vocabulary in
            EditVocabularyView(vocabulary: vocabulary)
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @StateObject private var userProgressService = UserProgressService.shared
    @StateObject private var languageService = LanguageService.shared
    @State private var showingSettings = false
    @State private var selectedLanguage = "it"
    @State private var showingLanguageSelector = false
    @State private var showingDailyGoalSetter = false
    @State private var showingNotificationSettings = false
    @State private var showingAccountSettings = false
    

    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with user info
                    userHeaderView
                    
                    // Statistics cards
                    statisticsView
                    
                    // Quick actions
                    quickActionsView
                    
                    // Settings section
                    settingsView
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color(hex: "3e4464"))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingLanguageSelector) {
                LanguageSelectorView(selectedLanguage: $selectedLanguage)
            }
            .sheet(isPresented: $showingDailyGoalSetter) {
                DailyGoalSetterView()
            }
            .sheet(isPresented: $showingNotificationSettings) {
                NotificationSettingsView()
            }
            .sheet(isPresented: $showingAccountSettings) {
                AccountSettingsView()
            }
            .onAppear {
                updateSelectedLanguageFromService()
            }
        }
    }
    
    private var userHeaderView: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: "fcc418"))
                    .frame(width: 80, height: 80)
                
                Text("👤")
                    .font(.system(size: 40))
            }
            
            // User info
            VStack(spacing: 8) {
                Text("Language Learner")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Learning \(getSelectedLanguageDisplay())")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                
                // Streak
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(Color(hex: "fcc418"))
                    Text("\(userProgressService.userProgress?.currentStreak ?? 0) day streak")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 20)
    }
    
    private var statisticsView: some View {
        VStack(spacing: 16) {
            Text("Your Progress")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    icon: "textformat",
                    title: "Vocabulary Words",
                    value: "\(languageService.getVocabularyCount())",
                    color: Color(hex: "3cc45b")
                )
                
                StatCard(
                    icon: "checkmark.circle.fill",
                    title: "Lessons Completed",
                    value: "\(languageService.getTotalLessonsCompleted())",
                    color: Color(hex: "fcc418")
                )
                
                StatCard(
                    icon: "clock.fill",
                    title: "Study Time",
                    value: "\(userProgressService.userProgress?.totalStudyTime ?? 0) min",
                    color: Color(hex: "3cc45b")
                )
                
                StatCard(
                    icon: "chart.bar.fill",
                    title: "Progress",
                    value: "\(Int(languageService.getCompletionPercentage() * 100))%",
                    color: Color(hex: "fcc418")
                )
            }
        }
    }
    
    private var quickActionsView: some View {
        VStack(spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                QuickActionButton(
                    title: "Daily Goal",
                    subtitle: "\(userProgressService.userProgress?.dailyGoal ?? 15) minutes",
                    icon: "target",
                    color: Color(hex: "3cc45b")
                ) {
                    showingDailyGoalSetter = true
                }
            }
        }
    }
    
    private var settingsView: some View {
        VStack(spacing: 16) {
            Text("Settings")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                SettingsRow(
                    title: "Language",
                    subtitle: getSelectedLanguageDisplay(),
                    icon: "globe",
                    action: {
                        showingLanguageSelector = true
                    }
                )
                
                SettingsRow(
                    title: "Notifications",
                    subtitle: "Reminders enabled",
                    icon: "bell.fill",
                    action: {
                        showingNotificationSettings = true
                    }
                )
                
                SettingsRow(
                    title: "Account",
                    subtitle: "Manage your account",
                    icon: "person.circle",
                    action: {
                        showingAccountSettings = true
                    }
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getSelectedLanguageDisplay() -> String {
        if let language = languageService.availableLanguages.first(where: { $0.code == selectedLanguage }) {
            return "\(language.name) \(language.flag)"
        }
        return "Italian 🇮🇹" // Default fallback
    }
    
    private func updateSelectedLanguageFromService() {
        selectedLanguage = languageService.selectedLanguage?.code ?? "it"
    }

}

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

struct QuickActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
        }
    }
}

struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
            .background(Color.black.opacity(0.2))
            .cornerRadius(12)
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "fcc418"))
            
            Text(achievement.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 80, height: 80)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

// MARK: - Placeholder Views
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
            .background(Color(hex: "3e4464").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                    .foregroundColor(Color(hex: "fcc418"))
                }
            }
        }
    }
}

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Achievements")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color(hex: "3e4464").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                    .foregroundColor(Color(hex: "fcc418"))
                }
            }
        }
    }
}

struct LanguageSelectorView: View {
    @Binding var selectedLanguage: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var languageService = LanguageService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose Language")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Select which language you want to learn")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 20)
                
                // Language grid
                languageGridView
                
                Spacer()
                
                // Done button
                Button(action: {
                    dismiss()
                }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "fcc418"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(hex: "3e4464").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                    .foregroundColor(Color(hex: "fcc418"))
                }
            }
        }
    }
    
    private var languageGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(availableLanguages) { language in
                    LanguageSelectionCard(
                        language: language,
                        isSelected: selectedLanguage == language.code
                    ) {
                        selectedLanguage = language.code
                        languageService.selectedLanguage = languageService.availableLanguages.first { $0.code == language.code }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var availableLanguages: [Language] {
        languageService.availableLanguages.filter { $0.code != "en" && $0.isAvailable }
    }
}

struct LanguageSelectionCard: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Flag
                Text(language.flag)
                    .font(.system(size: 40))
                
                // Language info
                VStack(spacing: 4) {
                    Text(language.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(language.code.uppercased())
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Selection indicator
                if isSelected {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "3cc45b"))
                        Text("Selected")
                            .font(.caption)
                            .foregroundColor(Color(hex: "3cc45b"))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(isSelected ? Color(hex: "3cc45b").opacity(0.2) : Color.white.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(hex: "3cc45b") : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct DailyGoalSetterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userProgressService = UserProgressService.shared
    @State private var selectedGoal: Int = 15
    
    let goalOptions = [5, 10, 15, 20, 30, 45, 60]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Daily Study Goal")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Set how many minutes you want to study each day")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Current goal display
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 8)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(getTodayProgress()))
                            .stroke(Color(hex: "3cc45b"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 4) {
                            Text("\(selectedGoal)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("minutes")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Text("Today: \(getTodayStudyTime()) / \(selectedGoal) min")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.vertical, 20)
                
                // Goal options
                VStack(spacing: 16) {
                    Text("Choose your goal")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(goalOptions, id: \.self) { goal in
                            Button(action: {
                                selectedGoal = goal
                            }) {
                                VStack(spacing: 8) {
                                    Text("\(goal)")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(selectedGoal == goal ? .black : .white)
                                    
                                    Text("min")
                                        .font(.caption)
                                        .foregroundColor(selectedGoal == goal ? .black.opacity(0.7) : .white.opacity(0.7))
                                }
                                .frame(height: 60)
                                .frame(maxWidth: .infinity)
                                .background(selectedGoal == goal ? Color(hex: "fcc418") : Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedGoal == goal ? Color(hex: "fcc418") : Color.clear, lineWidth: 2)
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Save button
                Button(action: {
                    saveGoal()
                }) {
                    Text("Save Goal")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "fcc418"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(hex: "3e4464").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color(hex: "fcc418"))
                }
            }
            .onAppear {
                selectedGoal = userProgressService.userProgress?.dailyGoal ?? 15
            }
        }
    }
    
    private func getTodayProgress() -> Double {
        let todayTime = getTodayStudyTime()
        return min(1.0, Double(todayTime) / Double(selectedGoal))
    }
    
    private func getTodayStudyTime() -> Int {
        guard let progress = userProgressService.userProgress else { return 0 }
        let today = Calendar.current.startOfDay(for: Date())
        
        if let todayProgress = progress.statistics.weeklyProgress.first(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            return todayProgress.minutesStudied
        }
        return 0
    }
    
    private func saveGoal() {
        guard var progress = userProgressService.userProgress else { return }
        progress.dailyGoal = selectedGoal
        userProgressService.updateUserProgress(progress)
        dismiss()
    }
}

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dailyRemindersEnabled = true
    @State private var streakRemindersEnabled = true
    @State private var achievementNotificationsEnabled = true
    @State private var weeklyReportsEnabled = true
    @State private var selectedReminderTime = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Notification Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Customize your learning reminders")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Daily reminders section
                        VStack(spacing: 16) {
                            HStack {
                                Text("Daily Reminders")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            NotificationToggleRow(
                                title: "Study Reminders",
                                subtitle: "Daily notifications to study",
                                icon: "bell.fill",
                                isOn: $dailyRemindersEnabled
                            )
                            
                            if dailyRemindersEnabled {
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Reminder Time")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                        Spacer()
                                    }
                                    
                                    DatePicker("", selection: $selectedReminderTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.wheel)
                                        .colorScheme(.dark)
                                        .frame(height: 120)
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Other notifications
                        VStack(spacing: 16) {
                            HStack {
                                Text("Other Notifications")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            NotificationToggleRow(
                                title: "Streak Reminders",
                                subtitle: "Don't break your learning streak",
                                icon: "flame.fill",
                                isOn: $streakRemindersEnabled
                            )
                            
                            NotificationToggleRow(
                                title: "Achievement Notifications",
                                subtitle: "Celebrate your progress",
                                icon: "trophy.fill",
                                isOn: $achievementNotificationsEnabled
                            )
                            
                            NotificationToggleRow(
                                title: "Weekly Reports",
                                subtitle: "Summary of your progress",
                                icon: "chart.bar.fill",
                                isOn: $weeklyReportsEnabled
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Save button
                Button(action: {
                    saveSettings()
                }) {
                    Text("Save Settings")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "fcc418"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(hex: "3e4464").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color(hex: "fcc418"))
                }
            }
        }
    }
    
    private func saveSettings() {
        // Save notification settings to UserDefaults
        UserDefaults.standard.set(dailyRemindersEnabled, forKey: "dailyRemindersEnabled")
        UserDefaults.standard.set(streakRemindersEnabled, forKey: "streakRemindersEnabled")
        UserDefaults.standard.set(achievementNotificationsEnabled, forKey: "achievementNotificationsEnabled")
        UserDefaults.standard.set(weeklyReportsEnabled, forKey: "weeklyReportsEnabled")
        UserDefaults.standard.set(selectedReminderTime, forKey: "reminderTime")
        
        dismiss()
    }
}

struct NotificationToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "fcc418"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "3cc45b")))
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AccountSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @StateObject private var userProgressService = UserProgressService.shared
    @StateObject private var languageService = LanguageService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Account Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Manage your profile and data")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 20)
                
                // Account info section
                VStack(spacing: 16) {
                    AccountInfoRow(title: "Profile", value: "Language Learner", icon: "person.circle")
                    AccountInfoRow(title: "Study Streak", value: "\(userProgressService.userProgress?.currentStreak ?? 0) days", icon: "flame.fill")
                    AccountInfoRow(title: "Total Lessons", value: "\(languageService.getTotalLessonsCompleted())", icon: "checkmark.circle")
                    AccountInfoRow(title: "Vocabulary Words", value: "\(languageService.getVocabularyCount())", icon: "textformat")
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Danger zone
                VStack(spacing: 16) {
                    Text("Danger Zone")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.white)
                            
                            Text("Delete Profile & All Data")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            .background(Color(hex: "3e4464").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                    .foregroundColor(Color(hex: "fcc418"))
                }
            }
            .alert("Delete Profile", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteProfile()
                }
            } message: {
                Text("Are you sure you want to delete your profile and all data? This action cannot be undone.\n\n• All lessons progress will be lost\n• All vocabulary words will be deleted\n• All achievements will be removed\n• Study streak will be reset")
            }
        }
    }
    
    private func deleteProfile() {
        // Reset user progress
        userProgressService.resetAllProgress()
        
        // Clear language service data
        languageService.resetAllData()
        
        // Dismiss the view
        dismiss()
    }
}

struct AccountInfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "fcc418"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct VocabularyActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                .font(.system(size: 24))
                    .foregroundColor(color)
            
                VStack(spacing: 4) {
                Text(title)
                        .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                    Text(subtitle)
                        .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        }
    }
}

struct RecentWordCard: View {
    let result: CameraRecognitionResult
    
    var body: some View {
        VStack(spacing: 8) {
            Text(result.objectName.capitalized)
                .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
            if let translation = result.translations.first?.value {
                Text(translation)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "fcc418"))
                }
            }
        .padding(12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
    }
}



// MARK: - User Vocabulary Components
struct UserVocabularyCard: View {
    let vocabulary: UserVocabulary
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(vocabulary.word)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(vocabulary.translation)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Added \(formatDate(vocabulary.dateAdded))")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
            HStack(spacing: 12) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.title3)
                        .foregroundColor(Color(hex: "fcc418"))
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct AddVocabularyView: View {
    @StateObject private var languageService = LanguageService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var word = ""
    @State private var translation = ""
    let selectedLanguage: String
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464").ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 20) {
                        // Language display
                        if let language = languageService.availableLanguages.first(where: { $0.code == selectedLanguage }) {
                                HStack {
                                Text(language.flag)
                                    .font(.title)
                                Text("Adding to \(language.name)")
                                    .font(.headline)
                                        .foregroundColor(.white)
                            }
                        }
                        
                        // Word input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Word")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Enter word", text: $word)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                        }
                        
                        // Translation input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Translation")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Enter translation", text: $translation)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                        }
                    }
                    
                    Spacer()
                    
                    // Add button
                    Button(action: {
                        languageService.addUserVocabulary(word, translation: translation, language: selectedLanguage)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Add Word")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canAdd ? Color(hex: "3cc45b") : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!canAdd)
                }
                .padding(20)
            }
            .navigationTitle("Add New Word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(hex: "fcc418"))
                }
            }
        }
    }
    
    private var canAdd: Bool {
        !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !translation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct EditVocabularyView: View {
    @StateObject private var languageService = LanguageService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var word: String
    @State private var translation: String
    let vocabulary: UserVocabulary
    
    init(vocabulary: UserVocabulary) {
        self.vocabulary = vocabulary
        self._word = State(initialValue: vocabulary.word)
        self._translation = State(initialValue: vocabulary.translation)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464").ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 20) {
                        // Language display
                        if let language = languageService.availableLanguages.first(where: { $0.code == vocabulary.language }) {
                            HStack {
                                Text(language.flag)
                                    .font(.title)
                                Text("Editing \(language.name) word")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Word input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Word")
                                .font(.headline)
                            .foregroundColor(.white)
                        
                            TextField("Enter word", text: $word)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                        }
                        
                        // Translation input
                            VStack(alignment: .leading, spacing: 8) {
                            Text("Translation")
                                .font(.headline)
                                    .foregroundColor(.white)
                            
                            TextField("Enter translation", text: $translation)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                        }
                    }
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        languageService.updateUserVocabulary(vocabulary.id, word: word, translation: translation)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save Changes")
                            .font(.headline)
                            .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canSave ? Color(hex: "3cc45b") : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!canSave)
                }
                .padding(20)
            }
            .navigationTitle("Edit Word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(hex: "fcc418"))
                }
            }
        }
    }
    
    private var canSave: Bool {
        !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !translation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}



#Preview {
    ContentView()
}
