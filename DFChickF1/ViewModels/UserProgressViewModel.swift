//
//  UserProgressViewModel.swift
//  LingoFusion
//
//  Created by IGOR on 08/08/2025.
//

import Foundation
import Combine

class UserProgressViewModel: ObservableObject {
    @Published var userProgress: UserProgress?
    @Published var todayProgress: DailyProgress?
    @Published var weeklyChallenge: WeeklyChallenge?
    @Published var recentAchievements: [Achievement] = []
    @Published var levelProgress: Double = 0.0
    @Published var streakData: [DailyProgress] = []
    @Published var isLoading: Bool = false
    
    private let userProgressService = UserProgressService.shared
    private let languageService = LanguageService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadUserProgress()
        setupWeeklyChallenge()
    }
    
    private func setupBindings() {
        userProgressService.$userProgress
            .assign(to: \.userProgress, on: self)
            .store(in: &cancellables)
        
        userProgressService.$userProgress
            .map { progress in
                guard let progress = progress else { return nil }
                let today = Calendar.current.startOfDay(for: Date())
                return progress.statistics.weeklyProgress.first { 
                    Calendar.current.isDate($0.date, inSameDayAs: today)
                }
            }
            .assign(to: \.todayProgress, on: self)
            .store(in: &cancellables)
        
        userProgressService.$userProgress
            .map { progress in
                guard let progress = progress else { return [] }
                return Array(progress.achievements.suffix(3))
            }
            .assign(to: \.recentAchievements, on: self)
            .store(in: &cancellables)
        
        userProgressService.$userProgress
            .map { progress in
                guard let progress = progress else { return 0.0 }
                let currentLevelXP = (progress.currentLevel - 1) * 1000
                let nextLevelXP = progress.currentLevel * 1000
                let progressInLevel = progress.totalXP - currentLevelXP
                return Double(progressInLevel) / Double(nextLevelXP - currentLevelXP)
            }
            .assign(to: \.levelProgress, on: self)
            .store(in: &cancellables)
    }
    
    private func loadUserProgress() {
        isLoading = true
        userProgressService.loadUserProgress()
        updateStreakData()
        isLoading = false
    }
    
    // MARK: - Weekly Challenge
    private func setupWeeklyChallenge() {
        guard let progress = userProgress else { return }
        
        if let existingChallenge = progress.weeklyChallenge,
           existingChallenge.endDate > Date() {
            weeklyChallenge = existingChallenge
        } else {
            createNewWeeklyChallenge()
        }
    }
    
    private func createNewWeeklyChallenge() {
        let challenges = [
            ("Study Streak", "Study for 5 days this week", ChallengeType.dailyStreak, 5, 200),
            ("Lesson Marathon", "Complete 10 lessons this week", ChallengeType.lessonsCompleted, 10, 300),
            ("Time Investment", "Study for 120 minutes this week", ChallengeType.studyMinutes, 120, 250),
            ("Vocabulary Boost", "Learn 25 new words this week", ChallengeType.wordsLearned, 25, 350),
            ("Camera Master", "Scan 15 objects this week", ChallengeType.cameraScans, 15, 200),
            ("Pronunciation Pro", "Complete 8 pronunciation exercises", ChallengeType.pronunciationPractice, 8, 300)
        ]
        
        let randomChallenge = challenges.randomElement()!
        let newChallenge = WeeklyChallenge(
            title: randomChallenge.0,
            description: randomChallenge.1,
            type: randomChallenge.2,
            target: randomChallenge.3,
            xpReward: randomChallenge.4
        )
        
        weeklyChallenge = newChallenge
        
        if var progress = userProgress {
            progress.weeklyChallenge = newChallenge
            userProgressService.updateUserProgress(progress)
        }
    }
    
    func updateWeeklyChallengeProgress() {
        guard var challenge = weeklyChallenge,
              let progress = userProgress else { return }
        
        let thisWeekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let thisWeekProgress = progress.statistics.weeklyProgress.filter { $0.date >= thisWeekStart }
        
        switch challenge.type {
        case .dailyStreak:
            challenge.progress = thisWeekProgress.count
        case .lessonsCompleted:
            challenge.progress = thisWeekProgress.reduce(0) { $0 + $1.lessonsCompleted }
        case .studyMinutes:
            challenge.progress = thisWeekProgress.reduce(0) { $0 + $1.minutesStudied }
        case .wordsLearned:
            // This would need to be tracked separately for weekly progress
            challenge.progress = min(challenge.target, progress.statistics.wordsLearned)
        case .cameraScans:
            challenge.progress = thisWeekProgress.reduce(0) { $0 + $1.cameraSessionsCompleted }
        case .pronunciationPractice:
            // This would need additional tracking
            challenge.progress = min(challenge.target, progress.lessonsCompleted)
        }
        
        if challenge.progress >= challenge.target && !challenge.isCompleted {
            challenge.isCompleted = true
            userProgressService.addXP(challenge.xpReward)
        }
        
        weeklyChallenge = challenge
        
        if var userProgress = userProgress {
            userProgress.weeklyChallenge = challenge
            userProgressService.updateUserProgress(userProgress)
        }
    }
    
    // MARK: - Streak Management
    private func updateStreakData() {
        guard let progress = userProgress else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        
        var streakDays: [DailyProgress] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: sevenDaysAgo)!
            
            if let existingProgress = progress.statistics.weeklyProgress.first(where: { 
                calendar.isDate($0.date, inSameDayAs: date)
            }) {
                streakDays.append(existingProgress)
            } else {
                streakDays.append(DailyProgress(date: date))
            }
        }
        
        streakData = streakDays
        updateCurrentStreak()
    }
    
    private func updateCurrentStreak() {
        guard var progress = userProgress else { return }
        
        var currentStreak = 0
        let sortedProgress = progress.statistics.weeklyProgress.sorted { $0.date > $1.date }
        
        for dailyProgress in sortedProgress {
            if dailyProgress.minutesStudied > 0 {
                currentStreak += 1
            } else {
                break
            }
        }
        
        progress.currentStreak = currentStreak
        progress.longestStreak = max(progress.longestStreak, currentStreak)
        
        userProgressService.updateUserProgress(progress)
    }
    
    // MARK: - Statistics
    func getTodayGoalProgress() -> Double {
        guard let progress = userProgress,
              let today = todayProgress else { return 0.0 }
        
        return Double(today.minutesStudied) / Double(progress.dailyGoal)
    }
    
    func getTotalLessonsCompleted() -> Int {
        return languageService.getTotalLessonsCompleted()
    }
    
    func getTotalVocabularyWords() -> Int {
        return languageService.getVocabularyCount()
    }
    
    func getOverallProgress() -> Double {
        return languageService.getCompletionPercentage()
    }
    
    func getWeeklyStudyMinutes() -> Int {
        return streakData.reduce(0) { $0 + $1.minutesStudied }
    }
    
    func getWeeklyLessonsCompleted() -> Int {
        return streakData.reduce(0) { $0 + $1.lessonsCompleted }
    }
    
    func getStudyDaysThisWeek() -> Int {
        return streakData.filter { $0.minutesStudied > 0 }.count
    }
    
    func getWeeklyXPEarned() -> Int {
        return streakData.reduce(0) { $0 + $1.xpEarned }
    }
    
    // MARK: - Level System
    func getXPNeededForNextLevel() -> Int {
        guard let progress = userProgress else { return 1000 }
        let nextLevelXP = progress.currentLevel * 1000
        return nextLevelXP - progress.totalXP
    }
    
    func getCurrentLevelXP() -> Int {
        guard let progress = userProgress else { return 0 }
        let currentLevelBaseXP = (progress.currentLevel - 1) * 1000
        return progress.totalXP - currentLevelBaseXP
    }
    
    func getXPForCurrentLevel() -> Int {
        return 1000 // Each level requires 1000 XP
    }
    
    // MARK: - Actions
    func resetDailyGoal(_ newGoal: Int) {
        guard var progress = userProgress else { return }
        progress.dailyGoal = max(5, min(180, newGoal))
        userProgressService.updateUserProgress(progress)
    }
    
    func markStudySession(minutes: Int) {
        userProgressService.updateDailyProgress(minutesStudied: minutes)
        updateWeeklyChallengeProgress()
        updateStreakData()
    }
    
    func refreshData() {
        loadUserProgress()
        updateWeeklyChallengeProgress()
    }
    
    // MARK: - Helper Methods
    func formatTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(remainingMinutes)m"
            }
        }
    }
    
    func getMotivationalMessage() -> String {
        guard let progress = userProgress else { return "Welcome to LingoFusion!" }
        
        let messages = [
            "Keep up the great work! 🚀",
            "You're on fire! 🔥",
            "Learning streak is strong! ⚡",
            "Amazing progress today! ⭐",
            "You're becoming fluent! 🌟",
            "Consistency is key! 💪",
            "Every lesson counts! 📚",
            "You're unstoppable! 🎯"
        ]
        
        if progress.currentStreak >= 7 {
            return "Week streak champion! 🏆"
        } else if progress.currentStreak >= 3 {
            return "Streak master! 🔥"
        } else if getTodayGoalProgress() >= 1.0 {
            return "Daily goal achieved! ⭐"
        } else {
            return messages.randomElement() ?? "Keep learning! 📚"
        }
    }
}