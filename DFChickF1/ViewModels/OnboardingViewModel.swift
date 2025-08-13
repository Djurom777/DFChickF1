//
//  OnboardingViewModel.swift
//  LingoFusion
//
//  Created by IGOR on 08/08/2025.
//

import Foundation
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var selectedLanguages: [Language] = []
    @Published var nativeLanguage: Language?
    @Published var difficultyLevel: DifficultyLevel = .beginner
    @Published var dailyGoal: Int = 15
    @Published var notificationsEnabled: Bool = true
    @Published var reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 19, minute: 0)) ?? Date()
    @Published var isCompleted: Bool = false
    
    private let languageService = LanguageService.shared
    private let userProgressService = UserProgressService.shared
    
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case languageSelection = 1
        case difficultyLevel = 2
        case goals = 3
        case notifications = 4
        case permissions = 5
        case completed = 6
        
        var title: String {
            switch self {
            case .welcome:
                return "Welcome to LingoFusion"
            case .languageSelection:
                return "Choose Your Language"
            case .difficultyLevel:
                return "What's Your Level?"
            case .goals:
                return "Set Your Goals"
            case .notifications:
                return "Stay Motivated"
            case .permissions:
                return "Enable Features"
            case .completed:
                return "You're All Set!"
            }
        }
        
        var description: String {
            switch self {
            case .welcome:
                return "Learn languages with interactive lessons and personalized vocabulary"
            case .languageSelection:
                return "Select the languages you want to learn"
            case .difficultyLevel:
                return "Help us personalize your learning experience"
            case .goals:
                return "How much time do you want to spend learning each day?"
            case .notifications:
                return "Get reminders to keep your learning streak alive"
            case .permissions:
                return "Set up notifications to maintain your learning streak"
            case .completed:
                return "Your personalized learning journey starts now!"
            }
        }
    }
    
    var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .languageSelection:
            return !selectedLanguages.isEmpty && nativeLanguage != nil
        case .difficultyLevel:
            return true
        case .goals:
            return dailyGoal >= 5
        case .notifications:
            return true
        case .permissions:
            return true
        case .completed:
            return true
        }
    }
    
    var progress: Double {
        return Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
    
    func nextStep() {
        guard canProceed else { return }
        
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        }
        
        if currentStep == .completed {
            completeOnboarding()
        }
    }
    
    func previousStep() {
        if let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            currentStep = previousStep
        }
    }
    
    func selectLanguage(_ language: Language) {
        if selectedLanguages.contains(where: { $0.id == language.id }) {
            selectedLanguages.removeAll { $0.id == language.id }
        } else {
            selectedLanguages.append(language)
        }
    }
    
    func setNativeLanguage(_ language: Language) {
        nativeLanguage = language
    }
    
    func setDifficultyLevel(_ level: DifficultyLevel) {
        difficultyLevel = level
    }
    
    func setDailyGoal(_ minutes: Int) {
        dailyGoal = max(5, min(120, minutes))
    }
    
    func toggleNotifications() {
        notificationsEnabled.toggle()
    }
    
    private func completeOnboarding() {
        // Save user preferences
        var preferences = UserPreferences()
        preferences.selectedLanguages = selectedLanguages.map { $0.code }
        preferences.nativeLanguage = nativeLanguage?.code ?? "en"
        preferences.difficultyPreference = difficultyLevel
        preferences.notificationsEnabled = notificationsEnabled
        preferences.reminderTime = reminderTime
        
        // Set up user progress
        var userProgress = UserProgress()
        userProgress.dailyGoal = dailyGoal
        userProgress.preferences = preferences
        
        // Update services
        if let nativeLanguage = nativeLanguage {
            languageService.setNativeLanguage(nativeLanguage)
        }
        if let firstSelectedLanguage = selectedLanguages.first {
            languageService.selectLanguage(firstSelectedLanguage)
        }
        
        userProgressService.updateUserProgress(userProgress)
        
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        isCompleted = true
    }
    
    func skipOnboarding() {
        // Set default values
        nativeLanguage = languageService.availableLanguages.first { $0.code == "en" }
        selectedLanguages = [languageService.availableLanguages.first { $0.code == "es" }].compactMap { $0 }
        difficultyLevel = .beginner
        dailyGoal = 15
        notificationsEnabled = false
        
        completeOnboarding()
    }
}

// MARK: - User Progress Service
class UserProgressService: ObservableObject {
    static let shared = UserProgressService()
    
    @Published var userProgress: UserProgress?
    
    private let userDefaultsKey = "userProgress"
    
    private init() {
        loadUserProgress()
    }
    
    func loadUserProgress() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            userProgress = progress
        } else {
            userProgress = UserProgress()
        }
    }
    
    func updateUserProgress(_ progress: UserProgress) {
        userProgress = progress
        saveUserProgress()
    }
    
    private func saveUserProgress() {
        guard let progress = userProgress,
              let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
    
    func addXP(_ amount: Int) {
        guard var progress = userProgress else { return }
        progress.totalXP += amount
        
        // Check for level up
        let newLevel = calculateLevel(from: progress.totalXP)
        if newLevel > progress.currentLevel {
            progress.currentLevel = newLevel
            // Could trigger level up animation/celebration here
        }
        
        updateUserProgress(progress)
    }
    
    func completeLesson(_ lesson: Lesson, score: Double) {
        guard var progress = userProgress else { return }
        
        progress.lessonsCompleted += 1
        let xpEarned = Int(score * 50) // Base XP based on score
        addXP(xpEarned)
        
        updateDailyProgress(minutesStudied: 5, lessonsCompleted: 1, xpEarned: xpEarned)
    }
    
    func updateDailyProgress(minutesStudied: Int = 0, lessonsCompleted: Int = 0, xpEarned: Int = 0, cameraScans: Int = 0) {
        guard var progress = userProgress else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        if let todayIndex = progress.statistics.weeklyProgress.firstIndex(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            progress.statistics.weeklyProgress[todayIndex].minutesStudied += minutesStudied
            progress.statistics.weeklyProgress[todayIndex].lessonsCompleted += lessonsCompleted
            progress.statistics.weeklyProgress[todayIndex].xpEarned += xpEarned
            progress.statistics.weeklyProgress[todayIndex].cameraSessionsCompleted += cameraScans
        } else {
            var dailyProgress = DailyProgress(date: today)
            dailyProgress.minutesStudied = minutesStudied
            dailyProgress.lessonsCompleted = lessonsCompleted
            dailyProgress.xpEarned = xpEarned
            dailyProgress.cameraSessionsCompleted = cameraScans
            progress.statistics.weeklyProgress.append(dailyProgress)
        }
        
        progress.totalStudyTime += minutesStudied
        updateUserProgress(progress)
    }
    
    private func calculateLevel(from xp: Int) -> Int {
        // Simple level calculation: every 1000 XP = 1 level
        return max(1, (xp / 1000) + 1)
    }
    
    func resetAllProgress() {
        userProgress = UserProgress()
        saveUserProgress()
    }
}