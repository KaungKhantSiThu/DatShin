//
//  ServiceFactoryProtocol.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import Foundation
//import TMDb // //import TMDb module

/// Protocol defining the interface for a service factory
protocol ServiceFactoryProtocol {
    /// Returns a service that conforms to the MoviesFetcher protocol
    /// Returns a service that conforms to the MovieServiceProtocol.
    func makeMovieService() -> MovieServiceProtocol
    
    /// Returns a service that conforms to the SearchServiceProtocol.
    func makeSearchService() -> SearchServiceProtocol
    
    /// Returns the request manager to be used by services
    
    /// Returns the default logger
    func makeDefaultLogger() -> LoggerProtocol
    
    /// Returns the network logger
    func makeNetworkLogger() -> LoggerProtocol
    
    /// Returns the UI logger
    func makeUILogger() -> LoggerProtocol
    
    /// Returns the data logger
    func makeDataLogger() -> LoggerProtocol
    
    /// Returns the coordinator logger
    func makeCoordinatorLogger() -> LoggerProtocol
    
    /// Returns a service that conforms to the TrendingServiceProtocol.
    func makeTrendingService() -> TrendingServiceProtocol
    
    /// Returns a service that conforms to the GenreServiceProtocol.
    func makeGenreService() -> GenreServiceProtocol
}
