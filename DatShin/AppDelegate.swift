//
//  AppDelegate.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 09/05/2024.
//

import UIKit
import os.log

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// Reference to the app coordinator
    var appCoordinator: AppCoordinator?
    
    lazy var coreDataStack: CoreDataStack = {
        return CoreDataStack(modelName: "DatShin")
    }()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize logging system
        setupLogging()
        
        return true
    }
    
    // MARK: - Logging Setup
    
    private func setupLogging() {
        // Initialize the logger factory to ensure loggers are created
        _ = LoggerFactory.shared
        
        // Log app launch
        Log.default.info("Application launched: \(Bundle.main.bundleIdentifier ?? "unknown") v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown")")
        
        // Add test logs with higher levels that will appear in console
        Log.default.error("TEST ERROR LOG - This should appear in the console")
        Log.default.critical("TEST CRITICAL LOG - This should definitely appear in the console")
        
        // Setup view controller lifecycle logging via method swizzling
//        UIViewController.swizzleViewControllerLifecycleMethods()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

