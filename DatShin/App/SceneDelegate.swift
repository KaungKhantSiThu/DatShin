//
//  SceneDelegate.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 09/05/2024.
//

import UIKit
import CoreSpotlight

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    fileprivate var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // Handle deep linking with coordinator
        guard let userInfo = userActivity.userInfo as? [String: Any],
              let identifier = userInfo[CSSearchableItemActivityIdentifier] as? String else {
                  return
              }
        
        // The coordinator could handle deep linking here
        // appCoordinator?.handleDeepLink(identifier: identifier)
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        print(#function)
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        print("Setting up service")
        // Set up the dependency injection container
        let serviceFactory = ServiceFactory()
        let viewControllerFactory = ViewControllerFactory(serviceFactory: serviceFactory)
        print("service done")

        // Initialize and start the app coordinator
        if let window = window {
            print("window not optional")

            appCoordinator = AppCoordinator(window: window, viewControllerFactory: viewControllerFactory)
            
            // Store reference in AppDelegate for global access
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                print("appDelegate not optional")

                appDelegate.appCoordinator = appCoordinator
            }
            
            appCoordinator?.start()
            
            // Set up debug gesture recognizer
            #if DEBUG
            setupDebugGestureRecognizer()
            #endif
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


// MARK: - Extension for SceneDelegate

extension SceneDelegate {
    /// Sets up the debug gesture recognizer
    func setupDebugGestureRecognizer() {
        guard let window = window, let appCoordinator = appCoordinator else { return }
        
        #if DEBUG
        // Only add the gesture recognizer in debug builds
        _ = DebugGestureRecognizer(window: window, appCoordinator: appCoordinator)
        #endif
    }
}
