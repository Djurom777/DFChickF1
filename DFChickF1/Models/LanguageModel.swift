//
//  LanguageModel.swift
//  LingoFusion
//
//  Created by IGOR on 08/08/2025.
//

import Foundation

// MARK: - Language Model
struct Language: Identifiable, Codable {
    let id: String
    let name: String
    let code: String
    let flag: String
    let isAvailable: Bool
    
    init(name: String, code: String, flag: String, isAvailable: Bool = true) {
        self.id = UUID().uuidString
        self.name = name
        self.code = code
        self.flag = flag
        self.isAvailable = isAvailable
    }
}

// MARK: - Learning Module Model
struct LearningModule: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let category: ModuleCategory
    let difficulty: DifficultyLevel
    let estimatedTime: Int // in minutes
    let lessons: [Lesson]
    let isUnlocked: Bool
    let progress: Double // 0.0 to 1.0
    
    init(title: String, description: String, category: ModuleCategory, difficulty: DifficultyLevel, estimatedTime: Int, lessons: [Lesson], isUnlocked: Bool, progress: Double) {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.estimatedTime = estimatedTime
        self.lessons = lessons
        self.isUnlocked = isUnlocked
        self.progress = progress
    }
}

enum ModuleCategory: String, CaseIterable, Codable {
    case basics = "Basics"
    case travel = "Travel"
    case business = "Business"
    case conversation = "Conversation"
    case grammar = "Grammar"
    case vocabulary = "Vocabulary"
    case pronunciation = "Pronunciation"
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

// MARK: - Lesson Model
struct Lesson: Identifiable, Codable {
    let id: String
    let title: String
    let content: [LessonContent]
    let type: LessonType
    let isCompleted: Bool
    let score: Double?
    
    init(title: String, content: [LessonContent], type: LessonType, isCompleted: Bool = false, score: Double? = nil) {
        self.id = UUID().uuidString
        self.title = title
        self.content = content
        self.type = type
        self.isCompleted = isCompleted
        self.score = score
    }
}

enum LessonType: String, CaseIterable, Codable {
    case vocabulary = "Vocabulary"
    case grammar = "Grammar"
    case listening = "Listening"
    case speaking = "Speaking"
    case writing = "Writing"
    case camera = "Camera Recognition"
    case translation = "Translation"
    case conversation = "Conversation"
}

// MARK: - Lesson Content Model
struct LessonContent: Identifiable, Codable {
    let id: String
    let type: ContentType
    let data: ContentData
    
    init(type: ContentType, data: ContentData) {
        self.id = UUID().uuidString
        self.type = type
        self.data = data
    }
}

enum ContentType: String, Codable {
    case text
    case audio
    case image
    case video
    case interactive
    case cameraTask
}

struct ContentData: Codable {
    let text: String?
    let audioURL: String?
    let imageURL: String?
    let videoURL: String?
    let interactiveData: [String: String]?
    
    init(text: String? = nil, audioURL: String? = nil, imageURL: String? = nil, videoURL: String? = nil, interactiveData: [String: String]? = nil) {
        self.text = text
        self.audioURL = audioURL
        self.imageURL = imageURL
        self.videoURL = videoURL
        self.interactiveData = interactiveData
    }
}

// MARK: - Translation Model
struct Translation: Identifiable, Codable {
    let id: String
    let originalText: String
    let translatedText: String
    let sourceLanguage: String
    let targetLanguage: String
    let timestamp: Date
    
    init(originalText: String, translatedText: String, sourceLanguage: String, targetLanguage: String) {
        self.id = UUID().uuidString
        self.originalText = originalText
        self.translatedText = translatedText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.timestamp = Date()
    }
}

// MARK: - Vocabulary Word Model
struct VocabularyWord: Identifiable, Codable {
    let id: String
    let word: String
    let translation: String
    let pronunciation: String?
    let example: String?
    let category: String
    let difficulty: DifficultyLevel
    let isLearned: Bool
    let learnedDate: Date?
    
    init(word: String, translation: String, pronunciation: String? = nil, example: String? = nil, category: String, difficulty: DifficultyLevel, isLearned: Bool = false, learnedDate: Date? = nil) {
        self.id = UUID().uuidString
        self.word = word
        self.translation = translation
        self.pronunciation = pronunciation
        self.example = example
        self.category = category
        self.difficulty = difficulty
        self.isLearned = isLearned
        self.learnedDate = learnedDate
    }
}

// MARK: - Camera Recognition Result
struct CameraRecognitionResult: Identifiable, Codable {
    let id: String
    let objectName: String
    let confidence: Double
    let translations: [String: String] // Language code : Translation
    let timestamp: Date
    
    init(objectName: String, confidence: Double, translations: [String: String]) {
        self.id = UUID().uuidString
        self.objectName = objectName
        self.confidence = confidence
        self.translations = translations
        self.timestamp = Date()
    }
}

// MARK: - Simple Lesson Models
struct SimpleLesson: Identifiable, Codable {
    let id: String
    let title: String
    let words: [SimpleWord]
    let language: String // language code
    var isCompleted: Bool
    
    init(title: String, words: [SimpleWord], language: String, isCompleted: Bool = false) {
        self.id = UUID().uuidString
        self.title = title
        self.words = words
        self.language = language
        self.isCompleted = isCompleted
    }
}

struct SimpleWord: Identifiable, Codable {
    let id: String
    let word: String
    let translation: String
    let pronunciation: String?
    
    init(word: String, translation: String, pronunciation: String? = nil) {
        self.id = UUID().uuidString
        self.word = word
        self.translation = translation
        self.pronunciation = pronunciation
    }
}

struct LanguageBlock: Identifiable, Codable {
    let id: String
    let language: Language
    var lessons: [SimpleLesson]
    var completedLessons: Int {
        lessons.filter { $0.isCompleted }.count
    }
    var totalLessons: Int {
        lessons.count
    }
    var progress: Double {
        guard totalLessons > 0 else { return 0.0 }
        return Double(completedLessons) / Double(totalLessons)
    }
    
    init(language: Language, lessons: [SimpleLesson]) {
        self.id = UUID().uuidString
        self.language = language
        self.lessons = lessons
    }
    
    mutating func updateLessonCompletion(_ lessonId: String, isCompleted: Bool) {
        if let index = lessons.firstIndex(where: { $0.id == lessonId }) {
            lessons[index].isCompleted = isCompleted
        }
    }
}

// MARK: - User Vocabulary (for third tab)
struct UserVocabulary: Identifiable, Codable {
    let id: String
    var word: String
    var translation: String
    let language: String // language code
    let dateAdded: Date
    
    init(word: String, translation: String, language: String) {
        self.id = UUID().uuidString
        self.word = word
        self.translation = translation
        self.language = language
        self.dateAdded = Date()
    }
}