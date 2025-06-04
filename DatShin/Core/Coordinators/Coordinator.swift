//
//  Coordinator.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import UIKit

/// Protocol defining the basic functionality of a coordinator
protocol Coordinator: AnyObject {
    /// The array of child coordinators
    var childCoordinators: [Coordinator] { get set }
    
    /// The navigation controller used by this coordinator
    var navigationController: UINavigationController { get set }
    
    /// Starts the coordinator's flow
    func start()
    
    /// Adds a child coordinator to the array of child coordinators
    func addChildCoordinator(_ coordinator: Coordinator)
    
    /// Removes a child coordinator from the array of child coordinators
    func removeChildCoordinator(_ coordinator: Coordinator)
    
    /// Removes all child coordinators
    func removeAllChildCoordinators()
}
