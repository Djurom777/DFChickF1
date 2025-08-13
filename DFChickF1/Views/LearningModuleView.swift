//
//  LearningModuleView.swift
//  LingoFusion
//
//  Created by IGOR on 08/08/2025.
//

import SwiftUI

struct LearningModuleView: View {
    @StateObject private var languageService = LanguageService.shared
    @State private var selectedLanguageBlock: LanguageBlock?
    @State private var selectedLesson: SimpleLesson?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464").ignoresSafeArea()
                
                if let selectedLanguageBlock = selectedLanguageBlock {
                    languageLessonsView(for: selectedLanguageBlock)
                } else {
                    languageBlocksView
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonDetailView(lesson: lesson) { lessonId in
                languageService.completeLesson(lessonId, in: lesson.language)
                selectedLesson = nil
            }
        }
    }
    
    private var languageBlocksView: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Language Learning")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        Text("Choose a language to start learning")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
            }
            .background(Color(hex: "3e4464"))
            
            // Language blocks list
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(languageService.languageBlocks) { block in
                        LanguageBlockCard(
                            block: block,
                            onTap: {
                                selectedLanguageBlock = block
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
    }
    
    private func languageLessonsView(for block: LanguageBlock) -> some View {
        VStack(spacing: 0) {
            // Header with back button
            VStack(spacing: 16) {
                HStack {
                    Button(action: {
                        selectedLanguageBlock = nil
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(Color(hex: "fcc418"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(block.language.flag)
                                .font(.title)
                            Text(block.language.name)
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                        }
                        
                        Text("\(block.completedLessons)/\(block.totalLessons) lessons completed")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                // Progress bar
                ProgressView(value: block.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "3cc45b")))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal, 20)
            }
            .background(Color(hex: "3e4464"))
            
            // Lessons list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(block.lessons.enumerated()), id: \.element.id) { index, lesson in
                        LessonCard(
                            lesson: lesson,
                            lessonNumber: index + 1,
                            onTap: {
                                selectedLesson = lesson
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

struct LanguageBlockCard: View {
    let block: LanguageBlock
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(block.language.flag)
                                .font(.title)
                            Text(block.language.name)
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.white)
                        }
                        
                        Text("\(block.completedLessons)/\(block.totalLessons) lessons")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("\(Int(block.progress * 100))%")
                            .font(.title3.bold())
                            .foregroundColor(Color(hex: "3cc45b"))
                        
                        Text("Complete")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Progress bar
                ProgressView(value: block.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "3cc45b")))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
            .padding(20)
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(block.progress > 0 ? Color(hex: "3cc45b").opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LessonCard: View {
    let lesson: SimpleLesson
    let lessonNumber: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Lesson number circle
                ZStack {
                    Circle()
                        .fill(lesson.isCompleted ? Color(hex: "3cc45b") : Color.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    if lesson.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    } else {
                        Text("\(lessonNumber)")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }
                }
                
                // Lesson info
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text("\(lesson.words.count) words")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Completion status
                if lesson.isCompleted {
                    VStack(spacing: 2) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "3cc45b"))
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Completed")
                            .font(.caption.weight(.medium))
                            .foregroundColor(Color(hex: "3cc45b"))
                    }
                } else {
                    VStack(spacing: 2) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Start")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(lesson.isCompleted ? Color(hex: "3cc45b").opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LessonDetailView: View {
    let lesson: SimpleLesson
    let onComplete: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 12) {
                            Text(lesson.title)
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("\(lesson.words.count) words to learn")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        // Words list
                        LazyVStack(spacing: 12) {
                            ForEach(lesson.words) { word in
                                WordCard(word: word)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Complete button
                        if !lesson.isCompleted {
                            Button(action: {
                                onComplete(lesson.id)
                            }) {
                                HStack {
                                    Text("Mark as Completed")
                                        .font(.headline.weight(.semibold))
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "3cc45b"))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(hex: "fcc418"))
                }
            }
        }
    }
}

struct WordCard: View {
    let word: SimpleWord
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(word.word)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                    
                    Text(word.translation)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Pronunciation hint if available
                if let pronunciation = word.pronunciation {
                    VStack(alignment: .trailing, spacing: 2) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title3)
                            .foregroundColor(Color(hex: "fcc418"))
                        
                        Text(pronunciation)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// Color extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    LearningModuleView()
}