//
//  LearningModuleViewModel.swift
//  LingoFusion
//
//  Created by IGOR on 08/08/2025.
//

import Foundation
import Combine
import AVFoundation

class LearningModuleViewModel: ObservableObject {
    @Published var modules: [LearningModule] = []
    @Published var selectedModule: LearningModule?
    @Published var currentLesson: Lesson?
    @Published var isLoading: Bool = false
    @Published var showingCameraView: Bool = false
    @Published var showingVoicePractice: Bool = false
    @Published var selectedCategory: ModuleCategory?
    @Published var selectedDifficulty: DifficultyLevel?
    @Published var searchText: String = ""
    
    // Camera-related properties
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var recognizedObjects: [CameraRecognitionResult] = []
    @Published var isScanning: Bool = false
    
    private let languageService = LanguageService.shared
    private let userProgressService = UserProgressService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadModules()
        checkCameraPermission()
    }
    
    // MARK: - Module Management
    func loadModules() {
        isLoading = true
        modules = languageService.getAvailableModules()
        isLoading = false
    }
    
    func selectModule(_ module: LearningModule) {
        selectedModule = module
    }
    
    func startLesson(_ lesson: Lesson) {
        currentLesson = lesson
        
        switch lesson.type {
        case .camera:
            showingCameraView = true
        case .speaking:
            showingVoicePractice = true
        default:
            // Handle other lesson types
            break
        }
    }
    
    func completeLesson(_ lesson: Lesson, score: Double) {
        userProgressService.completeLesson(lesson, score: score)
        
        // Update module progress
        if let moduleIndex = modules.firstIndex(where: { $0.id == selectedModule?.id }),
           let lessonIndex = modules[moduleIndex].lessons.firstIndex(where: { $0.id == lesson.id }) {
            
            // Create updated lesson
            var updatedLesson = lesson
            updatedLesson = Lesson(
                title: lesson.title,
                content: lesson.content,
                type: lesson.type,
                isCompleted: true,
                score: score
            )
            
            // Update module
            var updatedModule = modules[moduleIndex]
            var updatedLessons = updatedModule.lessons
            updatedLessons[lessonIndex] = updatedLesson
            
            let completedLessons = updatedLessons.filter { $0.isCompleted }.count
            let totalLessons = updatedLessons.count
            let newProgress = totalLessons > 0 ? Double(completedLessons) / Double(totalLessons) : 0.0
            
            updatedModule = LearningModule(
                title: updatedModule.title,
                description: updatedModule.description,
                category: updatedModule.category,
                difficulty: updatedModule.difficulty,
                estimatedTime: updatedModule.estimatedTime,
                lessons: updatedLessons,
                isUnlocked: updatedModule.isUnlocked,
                progress: newProgress
            )
            
            modules[moduleIndex] = updatedModule
            
            if selectedModule?.id == updatedModule.id {
                selectedModule = updatedModule
            }
        }
    }
    
    // MARK: - Filtering and Search
    func filteredModules() -> [LearningModule] {
        var filtered = modules
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        if let difficulty = selectedDifficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    func clearFilters() {
        selectedCategory = nil
        selectedDifficulty = nil
        searchText = ""
    }
    
    // MARK: - Camera Functionality
    func checkCameraPermission() {
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.cameraPermissionStatus = granted ? .authorized : .denied
                if granted {
                    self?.userProgressService.userProgress?.preferences.cameraPermissionGranted = true
                }
            }
        }
    }
    
    func startCameraScanning() {
        guard cameraPermissionStatus == .authorized else {
            requestCameraPermission()
            return
        }
        
        isScanning = true
        showingCameraView = true
    }
    
    func stopCameraScanning() {
        isScanning = false
        showingCameraView = false
    }
    
    func processRecognizedObject(_ objectName: String) {
        let result = languageService.recognizeObject(objectName)
        recognizedObjects.append(result)
        
        // Update user progress
        userProgressService.updateDailyProgress(cameraScans: 1)
        userProgressService.addXP(25) // Reward for using camera feature
        
        // Update vocabulary statistics
        if var progress = userProgressService.userProgress {
            progress.statistics.wordsLearned += 1
            userProgressService.updateUserProgress(progress)
        }
    }
    
    // MARK: - Voice Practice
    func startVoicePractice() {
        showingVoicePractice = true
    }
    
    func stopVoicePractice() {
        showingVoicePractice = false
    }
    
    func processSpeechResult(_ text: String, accuracy: Double) {
        // Update pronunciation accuracy
        if var progress = userProgressService.userProgress {
            let currentAccuracy = progress.statistics.pronunciationAccuracy
            let totalSessions = progress.statistics.weeklyProgress.reduce(0) { $0 + $1.lessonsCompleted }
            
            // Calculate weighted average
            let newAccuracy = totalSessions > 0 ? 
                ((currentAccuracy * Double(totalSessions)) + accuracy) / Double(totalSessions + 1) :
                accuracy
            
            progress.statistics.pronunciationAccuracy = newAccuracy
            userProgressService.updateUserProgress(progress)
        }
        
        userProgressService.addXP(Int(accuracy * 30)) // XP based on accuracy
    }
    
    // MARK: - Progress Tracking
    func getModuleProgress() -> Double {
        guard !modules.isEmpty else { return 0.0 }
        
        let totalProgress = modules.reduce(0.0) { $0 + $1.progress }
        return totalProgress / Double(modules.count)
    }
    
    func getCompletedModulesCount() -> Int {
        return modules.filter { $0.progress >= 1.0 }.count
    }
    
    func getUnlockedModulesCount() -> Int {
        return modules.filter { $0.isUnlocked }.count
    }
    
    // MARK: - Achievements
    func checkAchievements() {
        guard var progress = userProgressService.userProgress else { return }
        
        let achievements = [
            Achievement(
                title: "First Steps",
                description: "Complete your first lesson",
                icon: "star.fill",
                category: .lessons,
                requirement: 1,
                xpReward: 50
            ),
            Achievement(
                title: "Camera Explorer",
                description: "Scan 10 objects with the camera",
                icon: "camera.fill",
                category: .camera,
                requirement: 10,
                xpReward: 100
            ),
            Achievement(
                title: "Vocabulary Builder",
                description: "Learn 50 new words",
                icon: "book.fill",
                category: .vocabulary,
                requirement: 50,
                xpReward: 200
            ),
            Achievement(
                title: "Week Warrior",
                description: "Study for 7 consecutive days",
                icon: "flame.fill",
                category: .streak,
                requirement: 7,
                xpReward: 300
            ),
            Achievement(
                title: "Module Master",
                description: "Complete 3 learning modules",
                icon: "trophy.fill",
                category: .lessons,
                requirement: 3,
                xpReward: 500
            )
        ]
        
        for achievement in achievements {
            if !progress.achievements.contains(where: { $0.id == achievement.id }) {
                var mutableAchievement = achievement
                
                switch achievement.category {
                case .lessons:
                    mutableAchievement.progress = getCompletedModulesCount()
                case .camera:
                    mutableAchievement.progress = recognizedObjects.count
                case .vocabulary:
                    mutableAchievement.progress = progress.statistics.wordsLearned
                case .streak:
                    mutableAchievement.progress = progress.currentStreak
                default:
                    break
                }
                
                if mutableAchievement.progress >= mutableAchievement.requirement {
                    mutableAchievement.isUnlocked = true
                    progress.achievements.append(mutableAchievement)
                    userProgressService.addXP(mutableAchievement.xpReward)
                }
            }
        }
        
        userProgressService.updateUserProgress(progress)
    }
}