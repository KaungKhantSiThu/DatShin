import Foundation

// DependencyContainer.swift
protocol DependencyContainerProtocol {
    func resolve<T>() -> T
    func register<T>(factory: @escaping () -> T)
}

