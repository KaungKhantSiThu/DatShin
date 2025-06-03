final class ServiceFactory: ServiceFactoryProtocol {
    private let container: DependencyContainerProtocol
    
    init(container: DependencyContainerProtocol) {
        self.container = container
    }
    
    func makeRequestManager() -> RequestManagerProtocol {
        return RequestManager(
            apiManager: container.resolve(),
            parser: container.resolve()
        )
    }
    
    func makeMoviesFetcherService() -> MoviesFetcherServiceProtocol {
        return MoviesFetcherService(
            requestManager: makeRequestManager()
        )
    }
    
    func makeSearchService() -> SearchServiceProtocol {
        return SearchService(
            requestManager: makeRequestManager()
        )
    }
}