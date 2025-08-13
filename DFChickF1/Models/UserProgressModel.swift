//
//  UserProgressModel.swift
//  LingoFusion
//
//  Created by IGOR on 08/08/2025.
//

import Foundation

// MARK: - User Progress Model
struct UserProgress: Codable {
    var totalXP: Int
    var currentLevel: Int
    var currentStreak: Int
    var longestStreak: Int
    var lessonsCompleted: Int
    var totalStudyTime: Int // in minutes
    var dailyGoal: Int // in minutes
    var achievements: [Achievement]
    var statistics: LearningStatistics
    var weeklyChallenge: WeeklyChallenge?
    var preferences: UserPreferences
    
    init() {
        self.totalXP = 0
        self.currentLevel = 1
        self.currentStreak = 0
        self.longestStreak = 0
        self.lessonsCompleted = 0
        self.totalStudyTime = 0
        self.dailyGoal = 15
        self.achievements = []
        self.statistics = LearningStatistics()
        self.weeklyChallenge = nil
        self.preferences = UserPreferences()
    }
}

// MARK: - Learning Statistics
struct LearningStatistics: Codable {
    var wordsLearned: Int
    var pronunciationAccuracy: Double
    var favoriteCategory: ModuleCategory?
    var strongestSkill: LessonType?
    var weeklyProgress: [DailyProgress]
    var monthlyProgress: [WeeklyStats]
    
    init() {
        self.wordsLearned = 0
        self.pronunciationAccuracy = 0.0
        self.favoriteCategory = nil
        self.strongestSkill = nil
        self.weeklyProgress = []
        self.monthlyProgress = []
    }
}

// MARK: - Daily Progress
struct DailyProgress: Identifiable, Codable {
    let id: String
    let date: Date
    var minutesStudied: Int
    var lessonsCompleted: Int
    var xpEarned: Int
    var cameraSessionsCompleted: Int
    
    init(date: Date) {
        self.id = UUID().uuidString
        self.date = date
        self.minutesStudied = 0
        self.lessonsCompleted = 0
        self.xpEarned = 0
        self.cameraSessionsCompleted = 0
    }
}

// MARK: - Weekly Stats
struct WeeklyStats: Identifiable, Codable {
    let id: String
    let weekStartDate: Date
    var totalMinutes: Int
    var totalLessons: Int
    var totalXP: Int
    var averageAccuracy: Double
    
    init(weekStartDate: Date) {
        self.id = UUID().uuidString
        self.weekStartDate = weekStartDate
        self.totalMinutes = 0
        self.totalLessons = 0
        self.totalXP = 0
        self.averageAccuracy = 0.0
    }
}

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: Int
    var progress: Int
    var isUnlocked: Bool
    let xpReward: Int
    let unlockedDate: Date?
    
    init(title: String, description: String, icon: String, category: AchievementCategory, requirement: Int, xpReward: Int) {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.icon = icon
        self.category = category
        self.requirement = requirement
        self.progress = 0
        self.isUnlocked = false
        self.xpReward = xpReward
        self.unlockedDate = nil
    }
}

enum AchievementCategory: String, CaseIterable, Codable {
    case streak = "Streak"
    case lessons = "Lessons"
    case vocabulary = "Vocabulary"
    case camera = "Camera"
    case pronunciation = "Pronunciation"
    case translation = "Translation"
    case time = "Study Time"
}

// MARK: - Weekly Challenge
struct WeeklyChallenge: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let type: ChallengeType
    let target: Int
    var progress: Int
    let startDate: Date
    let endDate: Date
    let xpReward: Int
    var isCompleted: Bool
    
    init(title: String, description: String, type: ChallengeType, target: Int, xpReward: Int) {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.type = type
        self.target = target
        self.progress = 0
        self.startDate = Date()
        self.endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        self.xpReward = xpReward
        self.isCompleted = false
    }
}

enum ChallengeType: String, CaseIterable, Codable {
    case dailyStreak = "Daily Streak"
    case lessonsCompleted = "Lessons"
    case studyMinutes = "Study Time"
    case wordsLearned = "Vocabulary"
    case cameraScans = "Camera Scans"
    case pronunciationPractice = "Pronunciation"
}

// MARK: - User Preferences
struct UserPreferences: Codable {
    var selectedLanguages: [String] // Language codes
    var nativeLanguage: String
    var difficultyPreference: DifficultyLevel
    var notificationsEnabled: Bool
    var reminderTime: Date?
    var studyReminders: Bool
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var cameraPermissionGranted: Bool
    var microphonePermissionGranted: Bool
    
    init() {
        self.selectedLanguages = ["es"] // Default to Spanish
        self.nativeLanguage = "en"
        self.difficultyPreference = .beginner
        self.notificationsEnabled = true
        self.reminderTime = nil
        self.studyReminders = true
        self.soundEnabled = true
        self.hapticsEnabled = true
        self.cameraPermissionGranted = false
        self.microphonePermissionGranted = false
    }
}

// MARK: - Learning Session
struct LearningSession: Identifiable, Codable {
    let id: String
    let moduleId: String
    let lessonId: String
    let startTime: Date
    var endTime: Date?
    var completed: Bool
    var score: Double?
    var xpEarned: Int
    var mistakesMade: Int
    
    init(moduleId: String, lessonId: String) {
        self.id = UUID().uuidString
        self.moduleId = moduleId
        self.lessonId = lessonId
        self.startTime = Date()
        self.endTime = nil
        self.completed = false
        self.score = nil
        self.xpEarned = 0
        self.mistakesMade = 0
    }
}