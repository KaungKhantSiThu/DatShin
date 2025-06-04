//
//  BaseCoordinator.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import UIKit

/// Base implementation of the Coordinator protocol
class BaseCoordinator: Coordinator {
    // MARK: - Properties
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    /// Logger for coordinator events
    let logger: LoggerProtocol
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController, logger: LoggerProtocol = Log.coordinator) {
        self.navigationController = navigationController
        self.logger = logger
        
        logger.info("Initializing \(type(of: self))")
    }
    
    // MARK: - Coordinator
    
    func start() {
        logger.info("Starting \(type(of: self))")
        // To be implemented by subclasses
    }
    
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
        logger.debug("Added child coordinator: \(type(of: coordinator))")
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
            logger.debug("Removed child coordinator: \(type(of: coordinator))")
        } else {
            logger.warning("Attempted to remove child coordinator that doesn't exist: \(type(of: coordinator))")
        }
    }
    
    func removeAllChildCoordinators() {
        logger.debug("Removing all child coordinators from \(type(of: self))")
        childCoordinators.removeAll()
    }
}
