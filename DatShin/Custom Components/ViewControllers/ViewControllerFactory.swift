import UIKit

protocol ViewControllerFactoryProtocol {
    func makeHomeViewController() -> UIViewController
    func makeWatchListViewController() -> UIViewController
    func makeSearchViewController() -> UIViewController
    func makeTabBarController() -> UITabBarController
}

class ViewControllerFactory: ViewControllerFactoryProtocol {
    private let serviceFactory: ServiceFactoryProtocol
    
    init(serviceFactory: ServiceFactoryProtocol) {
        self.serviceFactory = serviceFactory
    }
    
    func makeHomeViewController() -> UIViewController {
        let fetcherService = serviceFactory.makeMoviesFetcherService()
        let viewController = HomeViewController(fetcherService: fetcherService)
        viewController.title = "Home"
        viewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        return UINavigationController(rootViewController: viewController)
    }
    
    func makeWatchListViewController() -> UIViewController {
        let fetcherService = serviceFactory.makeMoviesFetcherService()
        let viewController = WatchListViewController(fetcherService: fetcherService)
        viewController.title = "Watchlist"
        viewController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        return UINavigationController(rootViewController: viewController)
    }
    
    func makeSearchViewController() -> UIViewController {
        let searchService = serviceFactory.makeSearchService()
        let viewController = SearchViewController(service: searchService)
        viewController.title = "Search"
        viewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 2)
        return UINavigationController(rootViewController: viewController)
    }
    
    func makeTabBarController() -> UITabBarController {
        let tabBarController = TabBarController(serviceFactory: serviceFactory)
        tabBarController.viewControllers = [
            makeHomeViewController(),
            makeWatchListViewController(),
            makeSearchViewController()
        ]
        return tabBarController
    }
} 