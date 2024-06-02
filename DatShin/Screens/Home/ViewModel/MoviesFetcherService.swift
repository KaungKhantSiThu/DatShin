//
//  MoviesFetcherService.swift
//  Yote Shin
//
//  Created by Kaung Khant Si Thu on 10/04/2024.
//

import Foundation

actor MoviesFetcherService {
  private let requestManager: RequestManagerProtocol

  init(requestManager: RequestManagerProtocol) {
    self.requestManager = requestManager
  }
}

// MARK: - AnimalFetcher
extension MoviesFetcherService: MoviesFetcher {
    func fetchMovies(page: Int, section: Identifier) async throws -> [Movie] {
        let moviesContainer: MoviePageableList
    do {
        switch section {
        case .nowPlaying:
            moviesContainer = try await
            requestManager.get(endpoint: MoviesEndpoint.nowPlaying(page: page))
        case .popular:
            moviesContainer = try await
              requestManager.get(endpoint: MoviesEndpoint.popular(page: page))
        case .topRated:
            moviesContainer = try await
              requestManager.get(endpoint: MoviesEndpoint.topRated(page: page))
        case .upcoming:
            moviesContainer = try await
              requestManager.get(endpoint: MoviesEndpoint.upcoming(page: page))
        }
      
        return moviesContainer.results
    } catch {
      throw error
    }
  }
    
    func fetchDetail(forMovie movieID: Movie.ID) async throws -> Movie {
        return try await requestManager.get(endpoint: MoviesEndpoint.details(movieID: movieID))
    }
    
    func fetchCastAndCrew(forMovie movieID: Movie.ID) async throws -> ShowCredits {
        return try await requestManager.get(endpoint: MoviesEndpoint.credits(movieID: movieID))
    }
    
    func fetchSimilar(toMovie movieID: Movie.ID, page: Int? = nil) async throws -> [Movie] {
        let moviePageableList: MoviePageableList = try await requestManager.get(endpoint: MoviesEndpoint.similar(movieID: movieID, page: page))
        return moviePageableList.results
    }
    
    func fetchShowWatchProvider(forMovie movieID: Movie.ID) async throws -> ShowWatchProvider? {
        let result: ShowWatchProviderResult = try await requestManager.get(endpoint: MoviesEndpoint.watch(movieID: movieID))
        return result.results[Locale.current.region?.identifier ?? "us"]
    }
}
