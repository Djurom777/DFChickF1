//
//  LanguageService.swift
//  LingoFusion
//
//  Created by IGOR on 08/08/2025.
//

import Foundation
import Combine

// MARK: - Language Service
class LanguageService: ObservableObject {
    static let shared = LanguageService()
    
    @Published var availableLanguages: [Language] = []
    @Published var selectedLanguage: Language?
    @Published var nativeLanguage: Language?
    @Published var languageBlocks: [LanguageBlock] = []
    @Published var userVocabulary: [UserVocabulary] = []
    
    private init() {
        loadAvailableLanguages()
        setDefaultLanguages()
        setupLanguageBlocks()
        loadUserVocabulary()
    }
    
    // MARK: - Available Languages
    private func loadAvailableLanguages() {
        availableLanguages = [
            Language(name: "English", code: "en", flag: "🇺🇸"),
            Language(name: "Italian", code: "it", flag: "🇮🇹"),
            Language(name: "French", code: "fr", flag: "🇫🇷"),
            Language(name: "German", code: "de", flag: "🇩🇪"),
            Language(name: "Turkish", code: "tr", flag: "🇹🇷"),
            Language(name: "Japanese", code: "ja", flag: "🇯🇵", isAvailable: false),
        ]
    }
    
    private func setDefaultLanguages() {
        nativeLanguage = availableLanguages.first { $0.code == "en" }
        selectedLanguage = availableLanguages.first { $0.code == "it" }
    }
    
    // MARK: - Language Selection
    func selectLanguage(_ language: Language) {
        selectedLanguage = language
        UserDefaults.standard.set(language.code, forKey: "selectedLanguageCode")
    }
    
    func setNativeLanguage(_ language: Language) {
        nativeLanguage = language
        UserDefaults.standard.set(language.code, forKey: "nativeLanguageCode")
    }
    
    // MARK: - Translation Service
    func translateText(_ text: String, from sourceLanguage: String, to targetLanguage: String) -> String {
        // Simulated translation - In real app, you'd use Google Translate API or similar
        let commonTranslations: [String: [String: String]] = [
            "hello": [
                "es": "hola",
                "fr": "bonjour",
                "de": "hallo",
                "it": "ciao",
                "pt": "olá",
                "ja": "こんにちは",
                "ko": "안녕하세요",
                "zh": "你好"
            ],
            "goodbye": [
                "es": "adiós",
                "fr": "au revoir",
                "de": "auf wiedersehen",
                "it": "ciao",
                "pt": "tchau",
                "ja": "さようなら",
                "ko": "안녕히가세요",
                "zh": "再见"
            ],
            "thank you": [
                "es": "gracias",
                "fr": "merci",
                "de": "danke",
                "it": "grazie",
                "pt": "obrigado",
                "ja": "ありがとうございます",
                "ko": "감사합니다",
                "zh": "谢谢"
            ],
            "please": [
                "es": "por favor",
                "fr": "s'il vous plaît",
                "de": "bitte",
                "it": "per favore",
                "pt": "por favor",
                "ja": "お願いします",
                "ko": "제발",
                "zh": "请"
            ],
            "water": [
                "es": "agua",
                "fr": "eau",
                "de": "wasser",
                "it": "acqua",
                "pt": "água",
                "ja": "水",
                "ko": "물",
                "zh": "水"
            ],
            "food": [
                "es": "comida",
                "fr": "nourriture",
                "de": "essen",
                "it": "cibo",
                "pt": "comida",
                "ja": "食べ物",
                "ko": "음식",
                "zh": "食物"
            ],
            "house": [
                "es": "casa",
                "fr": "maison",
                "de": "haus",
                "it": "casa",
                "pt": "casa",
                "ja": "家",
                "ko": "집",
                "zh": "房子"
            ],
            "car": [
                "es": "coche",
                "fr": "voiture",
                "de": "auto",
                "it": "macchina",
                "pt": "carro",
                "ja": "車",
                "ko": "자동차",
                "zh": "汽车"
            ],
            "book": [
                "es": "libro",
                "fr": "livre",
                "de": "buch",
                "it": "libro",
                "pt": "livro",
                "ja": "本",
                "ko": "책",
                "zh": "书"
            ],
            "phone": [
                "es": "teléfono",
                "fr": "téléphone",
                "de": "telefon",
                "it": "telefono",
                "pt": "telefone",
                "ja": "電話",
                "ko": "전화",
                "zh": "电话"
            ]
        ]
        
        let lowerText = text.lowercased()
        if let translation = commonTranslations[lowerText]?[targetLanguage] {
            return translation
        }
        
        return "Translation not available"
    }
    
    // MARK: - Camera Object Recognition
    func recognizeObject(_ objectName: String) -> CameraRecognitionResult {
        let confidence = Double.random(in: 0.75...0.95)
        var translations: [String: String] = [:]
        
        for language in availableLanguages {
            if language.code != "en" {
                translations[language.code] = translateText(objectName, from: "en", to: language.code)
            }
        }
        
        return CameraRecognitionResult(
            objectName: objectName,
            confidence: confidence,
            translations: translations
        )
    }
    
    // MARK: - Learning Modules
    func getAvailableModules() -> [LearningModule] {
        return [
            LearningModule(
                title: "Travel Essentials", 
                description: "Essential phrases for travelers - hotels, transport, restaurants, directions",
                category: .travel,
                difficulty: .beginner,
                estimatedTime: 25,
                lessons: createTravelLessons(),
                isUnlocked: true,
                progress: 0.0
            ),
            LearningModule(
                title: "Business Conversations", 
                description: "Professional communication skills for workplace interactions",
                category: .business,
                difficulty: .intermediate,
                estimatedTime: 35,
                lessons: createBusinessLessons(),
                isUnlocked: true,
                progress: 0.0
            ),
            LearningModule(
                title: "Daily Conversations", 
                description: "Everyday conversations and common expressions",
                category: .conversation,
                difficulty: .beginner,
                estimatedTime: 20,
                lessons: createDailyLessons(),
                isUnlocked: true,
                progress: 0.0
            ),
            LearningModule(
                title: "Grammar Fundamentals", 
                description: "Essential grammar rules and structures",
                category: .grammar,
                difficulty: .intermediate,
                estimatedTime: 40,
                lessons: createGrammarLessons(),
                isUnlocked: false,
                progress: 0.0
            ),
            LearningModule(
                title: "Camera Recognition", 
                description: "Learn vocabulary by scanning real-world objects",
                category: .vocabulary,
                difficulty: .beginner,
                estimatedTime: 15,
                lessons: createCameraLessons(),
                isUnlocked: true,
                progress: 0.0
            ),
            LearningModule(
                title: "Pronunciation Master", 
                description: "Perfect your accent with voice recognition technology",
                category: .pronunciation,
                difficulty: .intermediate,
                estimatedTime: 30,
                lessons: createPronunciationLessons(),
                isUnlocked: false,
                progress: 0.0
            )
        ]
    }
    
    // MARK: - Helper Methods for Lessons
    private func createTravelLessons() -> [Lesson] {
        return [
            Lesson(title: "Airport & Transportation", content: [], type: .vocabulary),
            Lesson(title: "Hotel Check-in", content: [], type: .conversation),
            Lesson(title: "Restaurant Ordering", content: [], type: .speaking),
            Lesson(title: "Asking for Directions", content: [], type: .conversation),
            Lesson(title: "Emergency Phrases", content: [], type: .vocabulary)
        ]
    }
    
    private func createBusinessLessons() -> [Lesson] {
        return [
            Lesson(title: "Meeting Introductions", content: [], type: .conversation),
            Lesson(title: "Email Writing", content: [], type: .writing),
            Lesson(title: "Presenting Ideas", content: [], type: .speaking),
            Lesson(title: "Negotiation Phrases", content: [], type: .vocabulary),
            Lesson(title: "Business Etiquette", content: [], type: .conversation)
        ]
    }
    
    private func createDailyLessons() -> [Lesson] {
        return [
            Lesson(title: "Greetings & Introductions", content: [], type: .conversation),
            Lesson(title: "Family & Friends", content: [], type: .vocabulary),
            Lesson(title: "Shopping & Money", content: [], type: .conversation),
            Lesson(title: "Time & Weather", content: [], type: .vocabulary),
            Lesson(title: "Hobbies & Interests", content: [], type: .speaking)
        ]
    }
    
    private func createGrammarLessons() -> [Lesson] {
        return [
            Lesson(title: "Verb Conjugations", content: [], type: .grammar),
            Lesson(title: "Noun Genders", content: [], type: .grammar),
            Lesson(title: "Sentence Structure", content: [], type: .grammar),
            Lesson(title: "Questions & Answers", content: [], type: .conversation),
            Lesson(title: "Past & Future Tenses", content: [], type: .grammar)
        ]
    }
    
    private func createCameraLessons() -> [Lesson] {
        return [
            Lesson(title: "Household Objects", content: [], type: .camera),
            Lesson(title: "Food & Drinks", content: [], type: .camera),
            Lesson(title: "Outdoor Objects", content: [], type: .camera),
            Lesson(title: "Technology Items", content: [], type: .camera),
            Lesson(title: "Clothing & Accessories", content: [], type: .camera)
        ]
    }
    
    private func createPronunciationLessons() -> [Lesson] {
        return [
            Lesson(title: "Vowel Sounds", content: [], type: .speaking),
            Lesson(title: "Consonant Combinations", content: [], type: .speaking),
            Lesson(title: "Word Stress", content: [], type: .speaking),
            Lesson(title: "Sentence Rhythm", content: [], type: .speaking),
            Lesson(title: "Common Mistakes", content: [], type: .speaking)
        ]
    }
    
    // MARK: - Simple Lessons Management
    private func setupLanguageBlocks() {
        languageBlocks = availableLanguages.compactMap { language in
            guard language.code != "en" && language.isAvailable else { return nil } // Skip English and unavailable languages
            return LanguageBlock(language: language, lessons: createSimpleLessons(for: language.code))
        }
    }
    
    private func createSimpleLessons(for languageCode: String) -> [SimpleLesson] {
        let lessonData = getLessonData(for: languageCode)
        return lessonData.enumerated().map { index, lessonInfo in
            SimpleLesson(
                title: "Lesson \(index + 1): \(lessonInfo.theme)",
                words: lessonInfo.words,
                language: languageCode
            )
        }
    }
    
    private func getLessonData(for languageCode: String) -> [(theme: String, words: [SimpleWord])] {
        switch languageCode {
        case "it": // Italian
            return [
                ("Basic Greetings", [
                    SimpleWord(word: "Ciao", translation: "Hello/Bye"),
                    SimpleWord(word: "Buongiorno", translation: "Good morning"),
                    SimpleWord(word: "Buonasera", translation: "Good evening"),
                    SimpleWord(word: "Grazie", translation: "Thank you"),
                    SimpleWord(word: "Prego", translation: "You're welcome"),
                    SimpleWord(word: "Scusi", translation: "Excuse me"),
                    SimpleWord(word: "Buonanotte", translation: "Good night"),
                    SimpleWord(word: "Arrivederci", translation: "Goodbye"),
                    SimpleWord(word: "Salve", translation: "Hello (formal)"),
                    SimpleWord(word: "Come sta?", translation: "How are you?")
                ]),
                ("Family", [
                    SimpleWord(word: "Famiglia", translation: "Family"),
                    SimpleWord(word: "Madre", translation: "Mother"),
                    SimpleWord(word: "Padre", translation: "Father"),
                    SimpleWord(word: "Fratello", translation: "Brother"),
                    SimpleWord(word: "Sorella", translation: "Sister"),
                    SimpleWord(word: "Figlio", translation: "Son"),
                    SimpleWord(word: "Figlia", translation: "Daughter"),
                    SimpleWord(word: "Nonno", translation: "Grandfather"),
                    SimpleWord(word: "Nonna", translation: "Grandmother"),
                    SimpleWord(word: "Zio", translation: "Uncle")
                ]),
                ("Numbers", [
                    SimpleWord(word: "Uno", translation: "One"),
                    SimpleWord(word: "Due", translation: "Two"),
                    SimpleWord(word: "Tre", translation: "Three"),
                    SimpleWord(word: "Quattro", translation: "Four"),
                    SimpleWord(word: "Cinque", translation: "Five"),
                    SimpleWord(word: "Sei", translation: "Six"),
                    SimpleWord(word: "Sette", translation: "Seven"),
                    SimpleWord(word: "Otto", translation: "Eight"),
                    SimpleWord(word: "Nove", translation: "Nine"),
                    SimpleWord(word: "Dieci", translation: "Ten")
                ]),
                ("Colors", [
                    SimpleWord(word: "Rosso", translation: "Red"),
                    SimpleWord(word: "Blu", translation: "Blue"),
                    SimpleWord(word: "Verde", translation: "Green"),
                    SimpleWord(word: "Giallo", translation: "Yellow"),
                    SimpleWord(word: "Bianco", translation: "White"),
                    SimpleWord(word: "Nero", translation: "Black"),
                    SimpleWord(word: "Grigio", translation: "Gray"),
                    SimpleWord(word: "Rosa", translation: "Pink"),
                    SimpleWord(word: "Arancione", translation: "Orange"),
                    SimpleWord(word: "Viola", translation: "Purple")
                ]),
                ("Food", [
                    SimpleWord(word: "Pizza", translation: "Pizza"),
                    SimpleWord(word: "Pasta", translation: "Pasta"),
                    SimpleWord(word: "Pane", translation: "Bread"),
                    SimpleWord(word: "Acqua", translation: "Water"),
                    SimpleWord(word: "Vino", translation: "Wine"),
                    SimpleWord(word: "Formaggio", translation: "Cheese"),
                    SimpleWord(word: "Pomodoro", translation: "Tomato"),
                    SimpleWord(word: "Gelato", translation: "Ice cream"),
                    SimpleWord(word: "Caffè", translation: "Coffee"),
                    SimpleWord(word: "Carne", translation: "Meat")
                ]),
                ("Days of Week", [
                    SimpleWord(word: "Lunedì", translation: "Monday"),
                    SimpleWord(word: "Martedì", translation: "Tuesday"),
                    SimpleWord(word: "Mercoledì", translation: "Wednesday"),
                    SimpleWord(word: "Giovedì", translation: "Thursday"),
                    SimpleWord(word: "Venerdì", translation: "Friday"),
                    SimpleWord(word: "Sabato", translation: "Saturday"),
                    SimpleWord(word: "Domenica", translation: "Sunday"),
                    SimpleWord(word: "Oggi", translation: "Today"),
                    SimpleWord(word: "Ieri", translation: "Yesterday"),
                    SimpleWord(word: "Domani", translation: "Tomorrow")
                ]),
                ("Weather", [
                    SimpleWord(word: "Sole", translation: "Sun"),
                    SimpleWord(word: "Pioggia", translation: "Rain"),
                    SimpleWord(word: "Vento", translation: "Wind"),
                    SimpleWord(word: "Neve", translation: "Snow"),
                    SimpleWord(word: "Caldo", translation: "Hot"),
                    SimpleWord(word: "Freddo", translation: "Cold"),
                    SimpleWord(word: "Nuvoloso", translation: "Cloudy"),
                    SimpleWord(word: "Sereno", translation: "Clear"),
                    SimpleWord(word: "Tempesta", translation: "Storm"),
                    SimpleWord(word: "Umido", translation: "Humid")
                ]),
                ("Transportation", [
                    SimpleWord(word: "Auto", translation: "Car"),
                    SimpleWord(word: "Treno", translation: "Train"),
                    SimpleWord(word: "Autobus", translation: "Bus"),
                    SimpleWord(word: "Aereo", translation: "Airplane"),
                    SimpleWord(word: "Bicicletta", translation: "Bicycle"),
                    SimpleWord(word: "Metro", translation: "Subway"),
                    SimpleWord(word: "Taxi", translation: "Taxi"),
                    SimpleWord(word: "Barca", translation: "Boat"),
                    SimpleWord(word: "Moto", translation: "Motorcycle"),
                    SimpleWord(word: "Camminare", translation: "To walk")
                ]),
                ("Body Parts", [
                    SimpleWord(word: "Testa", translation: "Head"),
                    SimpleWord(word: "Occhi", translation: "Eyes"),
                    SimpleWord(word: "Naso", translation: "Nose"),
                    SimpleWord(word: "Bocca", translation: "Mouth"),
                    SimpleWord(word: "Mano", translation: "Hand"),
                    SimpleWord(word: "Piede", translation: "Foot"),
                    SimpleWord(word: "Braccio", translation: "Arm"),
                    SimpleWord(word: "Gamba", translation: "Leg"),
                    SimpleWord(word: "Orecchio", translation: "Ear"),
                    SimpleWord(word: "Corpo", translation: "Body")
                ]),
                ("Common Verbs", [
                    SimpleWord(word: "Essere", translation: "To be"),
                    SimpleWord(word: "Avere", translation: "To have"),
                    SimpleWord(word: "Andare", translation: "To go"),
                    SimpleWord(word: "Fare", translation: "To do/make"),
                    SimpleWord(word: "Vedere", translation: "To see"),
                    SimpleWord(word: "Parlare", translation: "To speak"),
                    SimpleWord(word: "Mangiare", translation: "To eat"),
                    SimpleWord(word: "Bere", translation: "To drink"),
                    SimpleWord(word: "Dormire", translation: "To sleep"),
                    SimpleWord(word: "Amare", translation: "To love")
                ])
            ]
        case "fr": // French
            return [
                ("Basic Greetings", [
                    SimpleWord(word: "Bonjour", translation: "Hello"),
                    SimpleWord(word: "Bonsoir", translation: "Good evening"),
                    SimpleWord(word: "Au revoir", translation: "Goodbye"),
                    SimpleWord(word: "Merci", translation: "Thank you"),
                    SimpleWord(word: "De rien", translation: "You're welcome"),
                    SimpleWord(word: "Excusez-moi", translation: "Excuse me"),
                    SimpleWord(word: "Bonne nuit", translation: "Good night"),
                    SimpleWord(word: "Salut", translation: "Hi/Bye"),
                    SimpleWord(word: "Comment allez-vous?", translation: "How are you?"),
                    SimpleWord(word: "À bientôt", translation: "See you soon")
                ]),
                ("Family", [
                    SimpleWord(word: "Famille", translation: "Family"),
                    SimpleWord(word: "Mère", translation: "Mother"),
                    SimpleWord(word: "Père", translation: "Father"),
                    SimpleWord(word: "Frère", translation: "Brother"),
                    SimpleWord(word: "Sœur", translation: "Sister"),
                    SimpleWord(word: "Fils", translation: "Son"),
                    SimpleWord(word: "Fille", translation: "Daughter"),
                    SimpleWord(word: "Grand-père", translation: "Grandfather"),
                    SimpleWord(word: "Grand-mère", translation: "Grandmother"),
                    SimpleWord(word: "Oncle", translation: "Uncle")
                ]),
                ("Numbers", [
                    SimpleWord(word: "Un", translation: "One"),
                    SimpleWord(word: "Deux", translation: "Two"),
                    SimpleWord(word: "Trois", translation: "Three"),
                    SimpleWord(word: "Quatre", translation: "Four"),
                    SimpleWord(word: "Cinq", translation: "Five"),
                    SimpleWord(word: "Six", translation: "Six"),
                    SimpleWord(word: "Sept", translation: "Seven"),
                    SimpleWord(word: "Huit", translation: "Eight"),
                    SimpleWord(word: "Neuf", translation: "Nine"),
                    SimpleWord(word: "Dix", translation: "Ten")
                ]),
                ("Colors", [
                    SimpleWord(word: "Rouge", translation: "Red"),
                    SimpleWord(word: "Bleu", translation: "Blue"),
                    SimpleWord(word: "Vert", translation: "Green"),
                    SimpleWord(word: "Jaune", translation: "Yellow"),
                    SimpleWord(word: "Blanc", translation: "White"),
                    SimpleWord(word: "Noir", translation: "Black"),
                    SimpleWord(word: "Gris", translation: "Gray"),
                    SimpleWord(word: "Rose", translation: "Pink"),
                    SimpleWord(word: "Orange", translation: "Orange"),
                    SimpleWord(word: "Violet", translation: "Purple")
                ]),
                ("Food", [
                    SimpleWord(word: "Pain", translation: "Bread"),
                    SimpleWord(word: "Eau", translation: "Water"),
                    SimpleWord(word: "Fromage", translation: "Cheese"),
                    SimpleWord(word: "Pomme", translation: "Apple"),
                    SimpleWord(word: "Vin", translation: "Wine"),
                    SimpleWord(word: "Café", translation: "Coffee"),
                    SimpleWord(word: "Viande", translation: "Meat"),
                    SimpleWord(word: "Poisson", translation: "Fish"),
                    SimpleWord(word: "Légume", translation: "Vegetable"),
                    SimpleWord(word: "Fruit", translation: "Fruit")
                ]),
                ("Days of Week", [
                    SimpleWord(word: "Lundi", translation: "Monday"),
                    SimpleWord(word: "Mardi", translation: "Tuesday"),
                    SimpleWord(word: "Mercredi", translation: "Wednesday"),
                    SimpleWord(word: "Jeudi", translation: "Thursday"),
                    SimpleWord(word: "Vendredi", translation: "Friday"),
                    SimpleWord(word: "Samedi", translation: "Saturday"),
                    SimpleWord(word: "Dimanche", translation: "Sunday"),
                    SimpleWord(word: "Aujourd'hui", translation: "Today"),
                    SimpleWord(word: "Hier", translation: "Yesterday"),
                    SimpleWord(word: "Demain", translation: "Tomorrow")
                ]),
                ("Weather", [
                    SimpleWord(word: "Soleil", translation: "Sun"),
                    SimpleWord(word: "Pluie", translation: "Rain"),
                    SimpleWord(word: "Vent", translation: "Wind"),
                    SimpleWord(word: "Neige", translation: "Snow"),
                    SimpleWord(word: "Chaud", translation: "Hot"),
                    SimpleWord(word: "Froid", translation: "Cold"),
                    SimpleWord(word: "Nuageux", translation: "Cloudy"),
                    SimpleWord(word: "Clair", translation: "Clear"),
                    SimpleWord(word: "Orage", translation: "Storm"),
                    SimpleWord(word: "Humide", translation: "Humid")
                ]),
                ("Transportation", [
                    SimpleWord(word: "Voiture", translation: "Car"),
                    SimpleWord(word: "Train", translation: "Train"),
                    SimpleWord(word: "Autobus", translation: "Bus"),
                    SimpleWord(word: "Avion", translation: "Airplane"),
                    SimpleWord(word: "Vélo", translation: "Bicycle"),
                    SimpleWord(word: "Métro", translation: "Subway"),
                    SimpleWord(word: "Taxi", translation: "Taxi"),
                    SimpleWord(word: "Bateau", translation: "Boat"),
                    SimpleWord(word: "Moto", translation: "Motorcycle"),
                    SimpleWord(word: "Marcher", translation: "To walk")
                ]),
                ("Body Parts", [
                    SimpleWord(word: "Tête", translation: "Head"),
                    SimpleWord(word: "Yeux", translation: "Eyes"),
                    SimpleWord(word: "Nez", translation: "Nose"),
                    SimpleWord(word: "Bouche", translation: "Mouth"),
                    SimpleWord(word: "Main", translation: "Hand"),
                    SimpleWord(word: "Pied", translation: "Foot"),
                    SimpleWord(word: "Bras", translation: "Arm"),
                    SimpleWord(word: "Jambe", translation: "Leg"),
                    SimpleWord(word: "Oreille", translation: "Ear"),
                    SimpleWord(word: "Corps", translation: "Body")
                ]),
                ("Common Verbs", [
                    SimpleWord(word: "Être", translation: "To be"),
                    SimpleWord(word: "Avoir", translation: "To have"),
                    SimpleWord(word: "Aller", translation: "To go"),
                    SimpleWord(word: "Faire", translation: "To do/make"),
                    SimpleWord(word: "Voir", translation: "To see"),
                    SimpleWord(word: "Parler", translation: "To speak"),
                    SimpleWord(word: "Manger", translation: "To eat"),
                    SimpleWord(word: "Boire", translation: "To drink"),
                    SimpleWord(word: "Dormir", translation: "To sleep"),
                    SimpleWord(word: "Aimer", translation: "To love")
                ])
            ]
        case "de": // German
            return [
                ("Basic Greetings", [
                    SimpleWord(word: "Hallo", translation: "Hello"),
                    SimpleWord(word: "Guten Tag", translation: "Good day"),
                    SimpleWord(word: "Auf Wiedersehen", translation: "Goodbye"),
                    SimpleWord(word: "Danke", translation: "Thank you"),
                    SimpleWord(word: "Bitte", translation: "Please/You're welcome"),
                    SimpleWord(word: "Entschuldigung", translation: "Excuse me"),
                    SimpleWord(word: "Guten Morgen", translation: "Good morning"),
                    SimpleWord(word: "Guten Abend", translation: "Good evening"),
                    SimpleWord(word: "Wie geht's?", translation: "How are you?"),
                    SimpleWord(word: "Tschüss", translation: "Bye")
                ]),
                ("Family", [
                    SimpleWord(word: "Familie", translation: "Family"),
                    SimpleWord(word: "Mutter", translation: "Mother"),
                    SimpleWord(word: "Vater", translation: "Father"),
                    SimpleWord(word: "Bruder", translation: "Brother"),
                    SimpleWord(word: "Schwester", translation: "Sister")
                ]),
                ("Numbers", [
                    SimpleWord(word: "Eins", translation: "One"),
                    SimpleWord(word: "Zwei", translation: "Two"),
                    SimpleWord(word: "Drei", translation: "Three"),
                    SimpleWord(word: "Vier", translation: "Four"),
                    SimpleWord(word: "Fünf", translation: "Five")
                ]),
                ("Colors", [
                    SimpleWord(word: "Rot", translation: "Red"),
                    SimpleWord(word: "Blau", translation: "Blue"),
                    SimpleWord(word: "Grün", translation: "Green"),
                    SimpleWord(word: "Gelb", translation: "Yellow"),
                    SimpleWord(word: "Weiß", translation: "White")
                ]),
                ("Food", [
                    SimpleWord(word: "Brot", translation: "Bread"),
                    SimpleWord(word: "Wasser", translation: "Water"),
                    SimpleWord(word: "Käse", translation: "Cheese"),
                    SimpleWord(word: "Apfel", translation: "Apple"),
                    SimpleWord(word: "Bier", translation: "Beer")
                ]),
                ("Days of Week", [
                    SimpleWord(word: "Montag", translation: "Monday"),
                    SimpleWord(word: "Dienstag", translation: "Tuesday"),
                    SimpleWord(word: "Mittwoch", translation: "Wednesday"),
                    SimpleWord(word: "Donnerstag", translation: "Thursday"),
                    SimpleWord(word: "Freitag", translation: "Friday")
                ]),
                ("Weather", [
                    SimpleWord(word: "Sonne", translation: "Sun"),
                    SimpleWord(word: "Regen", translation: "Rain"),
                    SimpleWord(word: "Wind", translation: "Wind"),
                    SimpleWord(word: "Schnee", translation: "Snow"),
                    SimpleWord(word: "Heiß", translation: "Hot")
                ]),
                ("Transportation", [
                    SimpleWord(word: "Auto", translation: "Car"),
                    SimpleWord(word: "Zug", translation: "Train"),
                    SimpleWord(word: "Bus", translation: "Bus"),
                    SimpleWord(word: "Flugzeug", translation: "Airplane"),
                    SimpleWord(word: "Fahrrad", translation: "Bicycle")
                ]),
                ("Body Parts", [
                    SimpleWord(word: "Kopf", translation: "Head"),
                    SimpleWord(word: "Augen", translation: "Eyes"),
                    SimpleWord(word: "Nase", translation: "Nose"),
                    SimpleWord(word: "Mund", translation: "Mouth"),
                    SimpleWord(word: "Hand", translation: "Hand")
                ]),
                ("Common Verbs", [
                    SimpleWord(word: "Sein", translation: "To be"),
                    SimpleWord(word: "Haben", translation: "To have"),
                    SimpleWord(word: "Gehen", translation: "To go"),
                    SimpleWord(word: "Machen", translation: "To do/make"),
                    SimpleWord(word: "Sehen", translation: "To see")
                ])
            ]
        case "tr": // Turkish
            return [
                ("Basic Greetings", [
                    SimpleWord(word: "Merhaba", translation: "Hello"),
                    SimpleWord(word: "Günaydın", translation: "Good morning"),
                    SimpleWord(word: "Hoşça kal", translation: "Goodbye"),
                    SimpleWord(word: "Teşekkürler", translation: "Thank you"),
                    SimpleWord(word: "Rica ederim", translation: "You're welcome")
                ]),
                ("Family", [
                    SimpleWord(word: "Aile", translation: "Family"),
                    SimpleWord(word: "Anne", translation: "Mother"),
                    SimpleWord(word: "Baba", translation: "Father"),
                    SimpleWord(word: "Kardeş", translation: "Sibling"),
                    SimpleWord(word: "Kız kardeş", translation: "Sister")
                ]),
                ("Numbers", [
                    SimpleWord(word: "Bir", translation: "One"),
                    SimpleWord(word: "İki", translation: "Two"),
                    SimpleWord(word: "Üç", translation: "Three"),
                    SimpleWord(word: "Dört", translation: "Four"),
                    SimpleWord(word: "Beş", translation: "Five")
                ]),
                ("Colors", [
                    SimpleWord(word: "Kırmızı", translation: "Red"),
                    SimpleWord(word: "Mavi", translation: "Blue"),
                    SimpleWord(word: "Yeşil", translation: "Green"),
                    SimpleWord(word: "Sarı", translation: "Yellow"),
                    SimpleWord(word: "Beyaz", translation: "White")
                ]),
                ("Food", [
                    SimpleWord(word: "Ekmek", translation: "Bread"),
                    SimpleWord(word: "Su", translation: "Water"),
                    SimpleWord(word: "Peynir", translation: "Cheese"),
                    SimpleWord(word: "Elma", translation: "Apple"),
                    SimpleWord(word: "Çay", translation: "Tea")
                ]),
                ("Days of Week", [
                    SimpleWord(word: "Pazartesi", translation: "Monday"),
                    SimpleWord(word: "Salı", translation: "Tuesday"),
                    SimpleWord(word: "Çarşamba", translation: "Wednesday"),
                    SimpleWord(word: "Perşembe", translation: "Thursday"),
                    SimpleWord(word: "Cuma", translation: "Friday")
                ]),
                ("Weather", [
                    SimpleWord(word: "Güneş", translation: "Sun"),
                    SimpleWord(word: "Yağmur", translation: "Rain"),
                    SimpleWord(word: "Rüzgar", translation: "Wind"),
                    SimpleWord(word: "Kar", translation: "Snow"),
                    SimpleWord(word: "Sıcak", translation: "Hot")
                ]),
                ("Transportation", [
                    SimpleWord(word: "Araba", translation: "Car"),
                    SimpleWord(word: "Tren", translation: "Train"),
                    SimpleWord(word: "Otobüs", translation: "Bus"),
                    SimpleWord(word: "Uçak", translation: "Airplane"),
                    SimpleWord(word: "Bisiklet", translation: "Bicycle")
                ]),
                ("Body Parts", [
                    SimpleWord(word: "Baş", translation: "Head"),
                    SimpleWord(word: "Göz", translation: "Eye"),
                    SimpleWord(word: "Burun", translation: "Nose"),
                    SimpleWord(word: "Ağız", translation: "Mouth"),
                    SimpleWord(word: "El", translation: "Hand")
                ]),
                ("Common Verbs", [
                    SimpleWord(word: "Olmak", translation: "To be"),
                    SimpleWord(word: "Sahip olmak", translation: "To have"),
                    SimpleWord(word: "Gitmek", translation: "To go"),
                    SimpleWord(word: "Yapmak", translation: "To do/make"),
                    SimpleWord(word: "Görmek", translation: "To see")
                ])
            ]
        default:
            return []
        }
    }
    
    // MARK: - Lesson Management
    func completeLesson(_ lessonId: String, in languageCode: String) {
        if let blockIndex = languageBlocks.firstIndex(where: { $0.language.code == languageCode }) {
            languageBlocks[blockIndex].updateLessonCompletion(lessonId, isCompleted: true)
            
            // Update progress statistics
            let userProgressService = UserProgressService.shared
            let xpReward = 50 // XP за завершение урока
            userProgressService.addXP(xpReward)
            userProgressService.updateDailyProgress(
                minutesStudied: 5, // Примерно 5 минут на урок
                lessonsCompleted: 1,
                xpEarned: xpReward
            )
            
            // Check for achievements
            checkForLessonAchievements(languageCode: languageCode)
        }
    }
    
    private func checkForLessonAchievements(languageCode: String) {
        guard UserProgressService.shared.userProgress != nil else { return }
        
        // Check if user completed all lessons for this language
        if let block = languageBlocks.first(where: { $0.language.code == languageCode }),
           block.completedLessons == block.totalLessons {
            
            // Award achievement for completing all lessons in a language
            UserProgressService.shared.addXP(200) // Bonus XP for language completion
        }
        
        // Check total lessons completed
        let totalCompleted = languageBlocks.reduce(0) { $0 + $1.completedLessons }
        
        // Award achievements based on milestones
        if totalCompleted == 5 {
            UserProgressService.shared.addXP(100) // First 5 lessons
        } else if totalCompleted == 10 {
            UserProgressService.shared.addXP(150) // First 10 lessons
        } else if totalCompleted == 25 {
            UserProgressService.shared.addXP(300) // 25 lessons milestone
        }
    }
    
    // MARK: - Statistics Methods
    func getTotalLessonsCompleted() -> Int {
        return languageBlocks.reduce(0) { $0 + $1.completedLessons }
    }
    
    func getTotalLessonsAvailable() -> Int {
        return languageBlocks.reduce(0) { $0 + $1.totalLessons }
    }
    
    func getCompletionPercentage() -> Double {
        let total = getTotalLessonsAvailable()
        guard total > 0 else { return 0.0 }
        return Double(getTotalLessonsCompleted()) / Double(total)
    }
    
    func getLanguageProgress(for languageCode: String) -> Double {
        guard let block = languageBlocks.first(where: { $0.language.code == languageCode }) else {
            return 0.0
        }
        return block.progress
    }
    
    func getVocabularyCount(for languageCode: String? = nil) -> Int {
        if let languageCode = languageCode {
            return userVocabulary.filter { $0.language == languageCode }.count
        }
        return userVocabulary.count
    }
    
    // MARK: - User Vocabulary Management
    private func loadUserVocabulary() {
        if let data = UserDefaults.standard.data(forKey: "userVocabulary"),
           let vocabulary = try? JSONDecoder().decode([UserVocabulary].self, from: data) {
            userVocabulary = vocabulary
        }
    }
    
    func addUserVocabulary(_ word: String, translation: String, language: String) {
        let newVocabulary = UserVocabulary(word: word, translation: translation, language: language)
        userVocabulary.append(newVocabulary)
        saveUserVocabulary()
    }
    
    func removeUserVocabulary(_ vocabularyId: String) {
        userVocabulary.removeAll { $0.id == vocabularyId }
        saveUserVocabulary()
    }
    
    func updateUserVocabulary(_ vocabularyId: String, word: String, translation: String) {
        if let index = userVocabulary.firstIndex(where: { $0.id == vocabularyId }) {
            userVocabulary[index].word = word
            userVocabulary[index].translation = translation
            saveUserVocabulary()
        }
    }
    
    private func saveUserVocabulary() {
        if let data = try? JSONEncoder().encode(userVocabulary) {
            UserDefaults.standard.set(data, forKey: "userVocabulary")
        }
    }
    
    func resetAllData() {
        // Reset all lesson progress
        for i in 0..<languageBlocks.count {
            for j in 0..<languageBlocks[i].lessons.count {
                languageBlocks[i].lessons[j].isCompleted = false
            }
        }
        
        // Clear user vocabulary
        userVocabulary.removeAll()
        saveUserVocabulary()
    }
}