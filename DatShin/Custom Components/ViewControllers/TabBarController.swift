//
//  TabBarController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 09/05/2024.
//

import UIKit

class TabBarController: UITabBarController {

    
    private let serviceFactory: ServiceFactoryProtocol
    private lazy var viewControllerFactory: ViewControllerFactoryProtocol = {
        return ViewControllerFactory(serviceFactory: serviceFactory)
    }()
    
    init(serviceFactory: ServiceFactoryProtocol) {
        self.serviceFactory = serviceFactory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = .systemGreen
        viewControllers = [
            viewControllerFactory.makeHomeViewController(),
            viewControllerFactory.makeWatchListViewController(),
            viewControllerFactory.makeSearchViewController()
        ]
    }
    
}
