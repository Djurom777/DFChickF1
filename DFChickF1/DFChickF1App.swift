//
//  DFChickF1App.swift
//  DFChickF1
//
//  Created by IGOR on 08/08/2025.
//

import SwiftUI
import Firebase

@main
struct DFChickF1App: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // инициализация Firebase SDK
        FirebaseApp.configure()
        return true
    }
}
