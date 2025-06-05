//
//  ServiceFactory.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import Foundation

/// Concrete implementation of ServiceFactoryProtocol
final class ServiceFactory: ServiceFactoryProtocol {
    // MARK: - TMDb Client
    private lazy var tmdbClient: TMDbClient = {
        return TMDbClient(apiKey: APIConstants.apiKey)
    }()

    // MARK: - Private Properties
    
    
    /// Logger factory for creating loggers
    private let loggerFactory = LoggerFactory.shared
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - ServiceFactoryProtocol
    
    func makeMovieService() -> MovieServiceProtocol {
        // Assuming MovieServiceProtocol is compatible with TMDb.MovieService
        // or an adapter will be used.
        // For now, let's assume direct compatibility or that MovieServiceProtocol
        // will be updated to match TMDb.MovieService.
        return tmdbClient.movies
    }
    
    func makeSearchService() -> SearchServiceProtocol {
        // Assuming SearchServiceProtocol is compatible with TMDb.SearchService
        // or an adapter will be used.
        // For now, let's assume direct compatibility or that SearchServiceProtocol
        // will be updated to match TMDb.SearchService.
        return tmdbClient.search // Now directly returns TMDb.SearchService, matching the updated protocol
    }
    
    
    func makeDefaultLogger() -> LoggerProtocol {
        return loggerFactory.defaultLogger
    }
    
    func makeNetworkLogger() -> LoggerProtocol {
        return loggerFactory.networkLogger
    }
    
    func makeUILogger() -> LoggerProtocol {
        return loggerFactory.uiLogger
    }
    
    func makeDataLogger() -> LoggerProtocol {
        return loggerFactory.dataLogger
    }
    
    func makeCoordinatorLogger() -> LoggerProtocol {
        return loggerFactory.coordinatorLogger
    }
    
    func makeTrendingService() -> TrendingServiceProtocol {
        return tmdbClient.trending
    }
    
    func makeGenreService() -> GenreServiceProtocol {
        return tmdbClient.genres
    }

    func makeConfigurationService() -> ConfigurationService {
        return tmdbClient.configurations
    }

    @MainActor func makeSearchResultsViewModel() -> SearchResultsViewModel {
        let searchService = makeSearchService() // Get the concrete SearchService
        let configurationService = makeConfigurationService() // Get the concrete ConfigurationService
        return SearchResultsViewModel(searchService: searchService, imageConfigurationService: configurationService)
    }
}
