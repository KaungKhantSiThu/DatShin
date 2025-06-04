//
//  DebugGestureRecognizer.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import UIKit

/// A utility class to add a debug gesture recognizer to the window
final class DebugGestureRecognizer {
    // MARK: - Properties
    
    /// The logger for this class
    private let logger: LoggerProtocol
    
    /// The window to add the gesture recognizer to
    private weak var window: UIWindow?
    
    /// The app coordinator to show the debug menu
    private weak var appCoordinator: AppCoordinator?
    
    // MARK: - Initialization
    
    /// Initialize with a window and app coordinator
    /// - Parameters:
    ///   - window: The window to add the gesture recognizer to
    ///   - appCoordinator: The app coordinator to show the debug menu
    ///   - logger: The logger to use
    init(window: UIWindow, appCoordinator: AppCoordinator, logger: LoggerProtocol = Log.default) {
        self.window = window
        self.appCoordinator = appCoordinator
        self.logger = logger
        
        setupGestureRecognizer()
    }
    
    // MARK: - Setup
    
    /// Sets up the gesture recognizer
    private func setupGestureRecognizer() {
        guard let window = window else { return }
        
        // Create a long press gesture recognizer that requires 4 fingers
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.numberOfTouchesRequired = 4
        longPressGesture.minimumPressDuration = 1.0
        
        // Add the gesture recognizer to the window
        window.addGestureRecognizer(longPressGesture)
        
        logger.debug("Debug gesture recognizer added to window")
    }
    
    // MARK: - Actions
    
    /// Handles the long press gesture
    /// - Parameter gesture: The gesture recognizer
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        logger.debug("Debug gesture recognized")
        
        // Show the debug menu
        appCoordinator?.showDebugMenu()
    }
}


