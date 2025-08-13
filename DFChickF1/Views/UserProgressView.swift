//
//  ProgressView.swift
//  LingoFusion
//
//  Created by IGOR on 08/08/2025.
//

import SwiftUI

struct UserProgressView: View {
    @StateObject private var viewModel = UserProgressViewModel()
    @State private var selectedTimeframe: TimeFrame = .week
    @State private var showingAchievementDetail = false
    @State private var selectedAchievement: Achievement?
    @State private var showingWeeklyGoal = false
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464").ignoresSafeArea()
                
                if viewModel.isLoading {
                    loadingView
                } else {
                    progressContent
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAchievementDetail) {
            if let achievement = selectedAchievement {
                AchievementDetailView(achievement: achievement)
            }
        }
        .sheet(isPresented: $showingWeeklyGoal) {
            WeeklyGoalView()
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "fcc418")))
            
            Text("Loading progress...")
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private var progressContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Level progress
                levelProgressView
                
                // Today's progress
                todayProgressView
                
                // Weekly challenge
                if let challenge = viewModel.weeklyChallenge {
                    WeeklyChallengeCard(challenge: challenge) {
                        showingWeeklyGoal = true
                    }
                }
                
                // Timeframe selector
                timeframeSelectorView
                
                // Statistics based on timeframe
                statisticsView
                
                // Streak calendar
                streakCalendarView
                
                // Recent achievements
                recentAchievementsView
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Progress")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(viewModel.getMotivationalMessage())
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "fcc418"))
                }
            }
            .padding(.top, 60)
        }
    }
    
    private var levelProgressView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Level \(viewModel.userProgress?.currentLevel ?? 1)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(viewModel.getCurrentLevelXP())/\(viewModel.getXPForCurrentLevel()) XP")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(viewModel.getXPNeededForNextLevel()) to next level")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            ProgressView(value: viewModel.levelProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "fcc418")))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            HStack(spacing: 24) {
                LevelStat(title: "Total XP", value: "\(viewModel.userProgress?.totalXP ?? 0)", icon: "star.fill")
                LevelStat(title: "Current Streak", value: "\(viewModel.userProgress?.currentStreak ?? 0)", icon: "flame.fill")
                LevelStat(title: "Best Streak", value: "\(viewModel.userProgress?.longestStreak ?? 0)", icon: "crown.fill")
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var todayProgressView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Goal")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Edit") {
                    // Edit daily goal
                }
                .font(.caption)
                .foregroundColor(Color(hex: "fcc418"))
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("\(viewModel.todayProgress?.minutesStudied ?? 0) / \(viewModel.userProgress?.dailyGoal ?? 15) min")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.getTodayGoalProgress() * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                ProgressView(value: viewModel.getTodayGoalProgress())
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "3cc45b")))
                
                HStack(spacing: 16) {
                    TodayStat(title: "Lessons", value: "\(viewModel.todayProgress?.lessonsCompleted ?? 0)")
                    TodayStat(title: "XP Earned", value: "\(viewModel.todayProgress?.xpEarned ?? 0)")
                    TodayStat(title: "Words", value: "\(viewModel.getTotalVocabularyWords())")
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var timeframeSelectorView: some View {
        HStack(spacing: 0) {
            ForEach(TimeFrame.allCases, id: \.rawValue) { timeframe in
                Button(timeframe.rawValue) {
                    selectedTimeframe = timeframe
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(selectedTimeframe == timeframe ? .black : .white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedTimeframe == timeframe ? Color(hex: "fcc418") : Color.clear)
                .animation(.easeInOut(duration: 0.2), value: selectedTimeframe)
            }
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var statisticsView: some View {
        VStack(spacing: 16) {
            Text("\(selectedTimeframe.rawValue) Overview")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatisticCard(
                    title: "Study Time",
                    value: viewModel.formatTime(getStudyTimeForTimeframe()),
                    subtitle: "Total minutes",
                    icon: "clock.fill",
                    color: Color(hex: "3cc45b"),
                    action: nil
                )
                
                StatisticCard(
                    title: "Lessons",
                    value: "\(getLessonsForTimeframe())",
                    subtitle: "Completed",
                    icon: "checkmark.circle.fill",
                    color: Color(hex: "fcc418"),
                    action: nil
                )
                
                StatisticCard(
                    title: "Progress",
                    value: "\(Int(viewModel.getOverallProgress() * 100))%",
                    subtitle: "Overall",
                    icon: "chart.bar.fill",
                    color: Color(hex: "007AFF"),
                    action: nil
                )
                
                StatisticCard(
                    title: "Study Days",
                    value: "\(getStudyDaysForTimeframe())",
                    subtitle: "Active days",
                    icon: "calendar.badge.checkmark",
                    color: Color(hex: "FF9500"),
                    action: nil
                )
            }
        }
    }
    
    private var streakCalendarView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("7-Day Streak")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(viewModel.streakData, id: \.id) { dayProgress in
                    StreakDayView(dayProgress: dayProgress)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var recentAchievementsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if viewModel.recentAchievements.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("No achievements yet")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Complete lessons to earn your first achievement")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.recentAchievements, id: \.id) { achievement in
                            RecentAchievementCard(achievement: achievement) {
                                selectedAchievement = achievement
                                showingAchievementDetail = true
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Helper Methods
    
    private func getStudyTimeForTimeframe() -> Int {
        switch selectedTimeframe {
        case .week:
            return viewModel.getWeeklyStudyMinutes()
        case .month:
            return viewModel.userProgress?.totalStudyTime ?? 0 // Simplified
        case .year:
            return viewModel.userProgress?.totalStudyTime ?? 0 // Simplified
        }
    }
    
    private func getLessonsForTimeframe() -> Int {
        switch selectedTimeframe {
        case .week:
            return viewModel.getWeeklyLessonsCompleted()
        case .month:
            return viewModel.userProgress?.lessonsCompleted ?? 0 // Simplified
        case .year:
            return viewModel.userProgress?.lessonsCompleted ?? 0 // Simplified
        }
    }
    
    private func getStudyDaysForTimeframe() -> Int {
        switch selectedTimeframe {
        case .week:
            return viewModel.getStudyDaysThisWeek()
        case .month:
            return 15 // Simplified
        case .year:
            return 120 // Simplified
        }
    }
}

// MARK: - Supporting Views

struct LevelStat: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "fcc418"))
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

struct TodayStat: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: (() -> Void)?
    
    var body: some View {
        Button(action: action ?? {}) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    if action != nil {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                VStack(spacing: 4) {
                    Text(value)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(16)
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
        }
        .disabled(action == nil)
    }
}

struct StreakDayView: View {
    let dayProgress: DailyProgress
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: dayProgress.date)
    }
    
    private var hasStudied: Bool {
        dayProgress.minutesStudied > 0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(dayName)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            ZStack {
                Circle()
                    .fill(hasStudied ? Color(hex: "fcc418") : Color.white.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                if hasStudied {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            
            Text("\(dayProgress.minutesStudied)")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

struct WeeklyChallengeCard: View {
    let challenge: WeeklyChallenge
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weekly Challenge")
                            .font(.caption)
                            .foregroundColor(Color(hex: "fcc418"))
                        
                        Text(challenge.title)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    if challenge.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "3cc45b"))
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                VStack(spacing: 8) {
                    HStack {
                        Text("\(challenge.progress)/\(challenge.target)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(challenge.xpReward) XP")
                            .font(.caption)
                            .foregroundColor(Color(hex: "fcc418"))
                    }
                    
                    ProgressView(value: Double(challenge.progress) / Double(challenge.target))
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "fcc418")))
                }
                
                Text(challenge.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
        }
    }
}

struct RecentAchievementCard: View {
    let achievement: Achievement
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "fcc418"))
                
                Text(achievement.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text("+\(achievement.xpReward) XP")
                    .font(.caption2)
                    .foregroundColor(Color(hex: "fcc418"))
            }
            .frame(width: 80, height: 80)
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
        }
    }
}

// MARK: - Placeholder Detail Views

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(achievement.title)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text(achievement.description)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .background(Color(hex: "3e4464"))
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

struct AllAchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("All Achievements")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color(hex: "3e4464"))
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

struct WeeklyGoalView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Weekly Goal")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color(hex: "3e4464"))
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

struct StudyHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Study History")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color(hex: "3e4464"))
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

struct StreakDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Streak Details")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color(hex: "3e4464"))
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

struct AccuracyBreakdownView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Accuracy Breakdown")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color(hex: "3e4464"))
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

#Preview {
    UserProgressView()
}