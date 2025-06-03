//
//  DependencyContainer.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 3/6/25.
//

import Foundation

final class DependencyContainer: DependencyContainerProtocol {
    private var factories: [String: () -> Any] = [:]
    
    func register<T>(factory: @escaping () -> T) {
        let key = String(describing: T.self)
        factories[key] = factory
    }
    
    func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let factory = factories[key] as? () -> T else {
            fatalError("No factory registered for \(key)")
        }
        return factory()
    }
}
