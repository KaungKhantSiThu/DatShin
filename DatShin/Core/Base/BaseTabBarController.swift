//
//  TabBarController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 09/05/2024.
//

import UIKit

class TabBarController: UITabBarController {
    
    // MARK: - Properties
    
    private let viewControllerFactory: ViewControllerFactoryProtocol
    
    // MARK: - Initialization
    
    init(viewControllerFactory: ViewControllerFactoryProtocol) {
        self.viewControllerFactory = viewControllerFactory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        setupViewControllers()
    }
    
    // MARK: - Configuration
    
    private func configureTabBar() {
        UITabBar.appearance().tintColor = .systemGreen
    }
    
    private func setupViewControllers() {
        // Create empty navigation controllers that will be populated by coordinators
        let watchlistNC = UINavigationController()
        watchlistNC.tabBarItem = UITabBarItem(title: "Watchlist", image: UIImage(systemName: "bookmark.fill"), tag: 0) // Using .bookmarks system item implies a title, let's be explicit or use a custom image
        // Let's ensure 'Watchlist' title is shown, as .bookmarks might not show it by default.
        // Or, if we want system item behavior: watchlistNC.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
        
        let discoverNC = UINavigationController() // Renamed from searchNC for clarity of its new role
        discoverNC.tabBarItem = UITabBarItem(title: "Discover", image: UIImage(systemName: "magnifyingglass"), tag: 1) // Using magnifying glass for 'Discover & Search'
        
        viewControllers = [discoverNC, watchlistNC]
    }
}
