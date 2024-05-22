//
//  TabBarController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 09/05/2024.
//

import UIKit

class TabBarController: UITabBarController {
    
    let fetcherService = MoviesFetcherService(requestManager: RequestManager())
    let searchService = SearchService(requestManager: RequestManager())

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = .systemGreen
        viewControllers = [createMoviesNC(), createFavoritesNC(), createSearchNC()]
    }
    
    func createMoviesNC() -> UINavigationController {
        let moviesVC = HomeViewController(fetcherService: fetcherService)
        moviesVC.title = "Home"
        moviesVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        let nc = UINavigationController(rootViewController: moviesVC)
        return nc
    }
    
    func createFavoritesNC() -> UINavigationController {
        let favoritesVC = FavoriteListViewController(fetcherService: fetcherService)
        favoritesVC.title = "Watchlist"
        favoritesVC.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        let nc = UINavigationController(rootViewController: favoritesVC)
        return nc
    }
    
    func createSearchNC() -> UINavigationController {
        let searchVC = SearchViewController(service: searchService)
        searchVC.title = "Search"
        searchVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 2)
        let nc = UINavigationController(rootViewController: searchVC)
        return nc
    }
    
}
