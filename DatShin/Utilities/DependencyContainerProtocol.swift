// DependencyContainer.swift
protocol DependencyContainerProtocol {
    func resolve<T>() -> T
    func register<T>(factory: @escaping () -> T)
}

// ServiceFactory.swift
protocol ServiceFactoryProtocol {
    func makeRequestManager() -> RequestManagerProtocol
    func makeMoviesFetcherService() -> MoviesFetcherServiceProtocol
    func makeSearchService() -> SearchServiceProtocol
    // Add other services as needed
}