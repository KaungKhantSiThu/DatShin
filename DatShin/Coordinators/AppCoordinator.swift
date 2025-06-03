import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let window: UIWindow
    private let serviceFactory: ServiceFactoryProtocol
    private let viewControllerFactory: ViewControllerFactoryProtocol
    
    init(window: UIWindow, serviceFactory: ServiceFactoryProtocol) {
        self.window = window
        self.serviceFactory = serviceFactory
        self.viewControllerFactory = ViewControllerFactory(serviceFactory: serviceFactory)
        self.navigationController = UINavigationController()
    }
    
    func start() {
        let tabBarController = viewControllerFactory.makeTabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    func showMovieDetail(for movie: Movie) {
        let detailCoordinator = MovieDetailCoordinator(
            navigationController: navigationController,
            movie: movie,
            serviceFactory: serviceFactory
        )
        childCoordinators.append(detailCoordinator)
        detailCoordinator.start()
    }
} 